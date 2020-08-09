package besman.steps

import besman.env.BesmanBashEnvBuilder
import besman.stubs.UnameStub

import java.util.zip.ZipException
import java.util.zip.ZipFile

import static cucumber.api.groovy.EN.And
import static besman.stubs.WebServiceStub.primeEndpointWithString
import static besman.stubs.WebServiceStub.primeSelfupdate
import static besman.support.UnixUtils.asBesmanPlatform

def BROADCAST_MESSAGE = "broadcast message"

And(~'^the besman work folder is created$') { ->
	assert besmanDir.isDirectory(), "The BESMAN directory does not exist."
}

And(~'^the "([^"]*)" folder exists in user home$') { String arg1 ->
	assert besmanDir.isDirectory(), "The BESMAN directory does not exist."
}

And(~'^the archive for candidate "([^"]*)" version "([^"]*)" is corrupt$') { String candidate, String version ->
	try {
		new ZipFile(new File("src/test/resources/__files/${candidate}-${version}.zip"))
		assert false, "Archive was not corrupt!"
	} catch (ZipException ze) {
		//expected behaviour
	}
}

And(~'^the archive for candidate "([^"]*)" version "([^"]*)" is removed$') { String candidate, String version ->
	def archive = new File("${besmanDir}/archives/${candidate}-${version}.zip")
	assert !archive.exists()
}

And(~'^the internet is reachable$') { ->
	primeEndpointWithString("/broadcast/latest/id", "12345")
	primeEndpointWithString("/broadcast/latest", BROADCAST_MESSAGE)
	primeEndpointWithString("/app/stable", besmanVersion)
	primeSelfupdate()

	offlineMode = false
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^the internet is not reachable$') { ->
	offlineMode = false
	serviceUrlEnv = SERVICE_DOWN_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is disabled with reachable internet$') { ->
	primeEndpointWithString("/broadcast/latest/id", "12345")
	primeEndpointWithString("/broadcast/latest", BROADCAST_MESSAGE)
	primeEndpointWithString("/app/stable", besmanVersion)

	offlineMode = false
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is enabled with reachable internet$') { ->
	primeEndpointWithString("/broadcast/latest/id", "12345")
	primeEndpointWithString("/broadcast/latest", BROADCAST_MESSAGE)
	primeEndpointWithString("/app/stable", besmanVersion)

	offlineMode = true
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is enabled with unreachable internet$') { ->
	offlineMode = true
	serviceUrlEnv = SERVICE_DOWN_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^a machine with "(.*)" installed$') { String platform ->
	def binFolder = "$besmanBaseDir/bin" as File
	UnameStub.prepareIn(binFolder)
			.forPlatform(asBesmanPlatform(platform))
			.build()
}

And(~'^an initialised environment$') { ->
	bash = BesmanBashEnvBuilder.create(besmanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withVersionCache(besmanVersion)
			.withCandidates(localCandidates)
			.withBesmanVersion(besmanVersion)
			.build()
}

And(~'^an initialised environment without debug prints$') { ->
	bash = BesmanBashEnvBuilder.create(besmanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withVersionCache(besmanVersion)
			.withCandidates(localCandidates)
			.withBesmanVersion(besmanVersion)
			.withDebugMode(false)
			.build()
}

And(~'^an outdated initialised environment$') { ->
	bash = BesmanBashEnvBuilder.create(besmanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withVersionCache(besmanVersionOutdated)
			.withBesmanVersion(besmanVersionOutdated)
			.build()

	def twoDaysAgoInMillis = System.currentTimeMillis() - 172800000

	def upgradeFile = "$besmanDir/var/delay_upgrade" as File
	upgradeFile.createNewFile()
	upgradeFile.setLastModified(twoDaysAgoInMillis)

	def versionFile = "$besmanDir/var/version" as File
	versionFile.setLastModified(twoDaysAgoInMillis)

	def initFile = "$besmanDir/bin/besman-init.sh" as File
	initFile.text = initFile.text.replace(besmanVersion, besmanVersionOutdated)
}

And(~'^the system is bootstrapped$') { ->
	bash.start()
	bash.execute("source $besmanDirEnv/bin/besman-init.sh")
}

And(~'^the system is bootstrapped again$') { ->
	bash.execute("source $besmanDirEnv/bin/besman-init.sh")
}

And(~/^the besman version is "([^"]*)"$/) { String version ->
	besmanVersion = version
}

And(~/^the candidates cache is initialised with "(.*)"$/) { String candidate ->
	localCandidates << candidate
}
