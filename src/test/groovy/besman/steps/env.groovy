package besman.steps

import com.github.tomakehurst.wiremock.client.WireMock
import besman.support.FilesystemUtils
import besman.support.UnixUtils
import besman.support.WireMockServerProvider

import static cucumber.api.groovy.Hooks.After
import static cucumber.api.groovy.Hooks.Before

HTTP_PROXY = System.getProperty("httpProxy") ?: ""
PLATFORM = UnixUtils.platform.toLowerCase()

FAKE_JDK_PATH = "/path/to/my/openjdk"
SERVICE_UP_HOST = "localhost"
SERVICE_UP_PORT = 8080
SERVICE_UP_URL = "http://$SERVICE_UP_HOST:$SERVICE_UP_PORT"
SERVICE_DOWN_URL = "http://localhost:0"

counter = "${(Math.random() * 10000).toInteger()}".padLeft(4, "0")

localGroovyCandidate = "/tmp/groovy-core" as File

besmanVersion = "5.0.0"
besmanVersionOutdated = "4.0.0"

besmanBaseEnv = FilesystemUtils.prepareBaseDir().absolutePath
besmanBaseDir = besmanBaseEnv as File

besmanDirEnv = "$besmanBaseEnv/.besman"
besmanDir = besmanDirEnv as File
candidatesDir = "${besmanDirEnv}/candidates" as File
binDir = "${besmanDirEnv}/bin" as File
srcDir = "${besmanDirEnv}/src" as File
varDir = "${besmanDirEnv}/var" as File
etcDir = "${besmanDirEnv}/etc" as File
extDir = "${besmanDirEnv}/ext" as File
archiveDir = "${besmanDirEnv}/archives" as File
tmpDir = "${besmanDir}/tmp" as File

broadcastFile = new File(varDir, "broadcast")
broadcastIdFile = new File(varDir, "broadcast_id")
candidatesFile = new File(varDir, "candidates")
versionFile = new File(varDir, "version")
initScript = new File(binDir, "besman-init.sh")

localCandidates = ['groovy', 'grails', 'java', 'kotlin', 'scala']

bash = null

if (!binding.hasVariable("wireMock")) {
	wireMock = WireMockServerProvider.wireMockServer()
}

addShutdownHook {
	wireMock.stop()
}

Before() {
	WireMock.reset()
	cleanUp()
}

private cleanUp() {
	besmanBaseDir.deleteDir()
	localGroovyCandidate.deleteDir()
}

After() { scenario ->
	def output = bash?.output
	if (output) {
		scenario.write("\nOutput: \n${output}")
	}
	bash?.stop()
}
