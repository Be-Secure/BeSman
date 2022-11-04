package besman.steps

import java.nio.file.FileSystems
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

import static cucumber.api.groovy.EN.And
import static java.nio.file.Files.isSameFile
import static java.nio.file.Files.isSymbolicLink
import static besman.support.FilesystemUtils.prepareCandidateBinFolder
import static besman.support.FilesystemUtils.prepareCandidateWithVersionFolder

And(~'^the candidate "([^"]*)" version "([^"]*)" is installed$') { String candidate, String version ->
	def file = "${candidatesDir}/${candidate}/${version}" as File
	if (!file.exists()) println bash.output
	assert file.exists()
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is not installed$') { String candidate, String version ->
	def directory = FileSystems.default.getPath("$candidatesDir/$candidate/$version")
	if (Files.exists(directory)) println bash.output
	assert !Files.exists(directory)
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is already installed and default$') { String candidate, String version ->
	def candidateVersion = prepareCandidateWithVersionFolder("$candidatesDir", candidate, version)
	def currentLink = FileSystems.default.getPath("$candidatesDir/$candidate/current")
	Files.createSymbolicLink currentLink, candidateVersion
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is the default$') { String candidate, String version ->
	def localVersion = FileSystems.default.getPath("$candidatesDir/$candidate/$version")
	def currentLink = FileSystems.default.getPath("$candidatesDir/$candidate/current")
	Files.createSymbolicLink currentLink, localVersion
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is already installed but not default$') { String candidate, String version ->
	prepareCandidateWithVersionFolder "$candidatesDir", candidate, version
}

And(~'^I do not have a "([^"]*)" candidate installed$') { String candidate ->
	def candidateDir = FileSystems.default.getPath("${candidatesDir}/${candidate}")
	assert !candidateDir.toFile().listFiles()
}

And(~'^the candidate "([^"]*)" does not exist locally$') { String candidate ->
	def candidateDir = "${candidatesDir}/${candidate}" as File
	candidateDir.deleteDir()
	assert !candidateDir.exists()
}

And(~'^I have a local candidate "([^"]*)" version "([^"]*)" at "([^"]*)"$') { String candidate, String version, String directory ->
	prepareCandidateBinFolder directory, candidate, version
}

And(~'^I have a local candidate "([^"]*)" version "([^"]*)" at relative path "([^"]*)"$') { String candidate, String version, String relativePath ->
	def fullPath = new File(besmanBaseDir.absolutePath, relativePath)
	prepareCandidateBinFolder fullPath.absolutePath, candidate, version
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is linked to the relative path "([^"]*)"$') { String candidate, String version, String relativePath ->
	def fullPath = new File(besmanBaseDir.absolutePath, relativePath)
	assertLinkedCandidate(fullPath.absolutePath, candidate, version)
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is linked to "([^"]*)"$') { String candidate, String version, String directory ->
	assertLinkedCandidate(directory, candidate, version)
}

def assertLinkedCandidate(String directory, String candidate, String version) {
	Path versionFolder = Paths.get("$candidatesDir/$candidate/$version")

	assert isSymbolicLink(versionFolder)

	assert isSameFile(versionFolder, Paths.get(directory))
}

And(~'^the candidate "([^"]*)" version "([^"]*)" is already linked to "([^"]*)"$') { String candidate, String version, String folder ->
	def fileSystem = FileSystems.default

	def candidateFolder = "$candidatesDir/$candidate" as File
	candidateFolder.mkdirs()

	def link = fileSystem.getPath("$candidatesDir/$candidate/$version")
	def target = prepareCandidateBinFolder(folder, candidate, version)

	Files.createSymbolicLink(link, target)
}

And(~'^I have configured "([^"]*)" to "([^"]*)"$') { String configName, String flag ->
	def configFile = new File("$besmanDir/etc/config")
	configFile.write "${configName}=${flag}"
}

And(~/^the exit code is (\d+)$/) { Integer rc ->
	assert bash.getStatus() == rc
}
