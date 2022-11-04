package besman.env

import groovy.transform.ToString
import besman.stubs.CurlStub

@ToString(includeNames = true)
class BesmanBashEnvBuilder {

	final TEST_SCRIPT_BUILD_DIR = "build/scripts" as File

	//mandatory fields
	private final File baseFolder

	//optional fields with sensible defaults
	private Optional<CurlStub> curlStub = Optional.empty()
	private List candidates = ['groovy', 'grails', 'java']
	private boolean offlineMode = false
	private String broadcast = "This is a LIVE broadcast!"
	private String candidatesApi = "http://localhost:8080/2"
	private String besmanVersion = "5.0.0"
	private String jdkHome = "/path/to/my/jdk"
	private String httpProxy
	private String versionCache
	private boolean debugMode = true

	Map config = [
			besman_auto_answer : 'false',
			besman_beta_channel: 'false'
	]

	File besmanDir, besmanBinDir, besmanVarDir, besmanSrcDir, besmanEtcDir, besmanExtDir, besmanArchivesDir, besmanTmpDir, besmanCandidatesDir

	static BesmanBashEnvBuilder create(File baseFolder) {
		new BesmanBashEnvBuilder(baseFolder)
	}

	private BesmanBashEnvBuilder(File baseFolder) {
		this.baseFolder = baseFolder
	}

	BesmanBashEnvBuilder withCurlStub(CurlStub curlStub) {
		this.curlStub = Optional.of(curlStub)
		this
	}

	BesmanBashEnvBuilder withCandidates(List candidates) {
		this.candidates = candidates
		this
	}

	BesmanBashEnvBuilder withBroadcast(String broadcast) {
		this.broadcast = broadcast
		this
	}

	BesmanBashEnvBuilder withConfiguration(String key, String value) {
		config.put key, value
		this
	}

	BesmanBashEnvBuilder withOfflineMode(boolean offlineMode) {
		this.offlineMode = offlineMode
		this
	}

	BesmanBashEnvBuilder withCandidatesApi(String service) {
		this.candidatesApi = service
		this
	}

	BesmanBashEnvBuilder withJdkHome(String jdkHome) {
		this.jdkHome = jdkHome
		this
	}

	BesmanBashEnvBuilder withHttpProxy(String httpProxy) {
		this.httpProxy = httpProxy
		this
	}

	BesmanBashEnvBuilder withVersionCache(String version) {
		this.versionCache = version
		this
	}

	BesmanBashEnvBuilder withBesmanVersion(String version) {
		this.besmanVersion = version
		this
	}

	BesmanBashEnvBuilder withDebugMode(boolean debugMode) {
		this.debugMode = debugMode
		this
	}

	BashEnv build() {
		besmanDir = prepareDirectory(baseFolder, ".besman")
		besmanBinDir = prepareDirectory(besmanDir, "bin")
		besmanVarDir = prepareDirectory(besmanDir, "var")
		besmanSrcDir = prepareDirectory(besmanDir, "src")
		besmanEtcDir = prepareDirectory(besmanDir, "etc")
		besmanExtDir = prepareDirectory(besmanDir, "ext")
		besmanArchivesDir = prepareDirectory(besmanDir, "archives")
		besmanTmpDir = prepareDirectory(besmanDir, "tmp")
		besmanCandidatesDir = prepareDirectory(besmanDir, "candidates")

		curlStub.map { cs -> cs.build() }

		initializeCandidates(besmanCandidatesDir, candidates)
		initializeCandidatesCache(besmanVarDir, candidates)
		initializeBroadcast(besmanVarDir, broadcast)
		initializeConfiguration(besmanEtcDir, config)
		initializeVersionCache(besmanVarDir, versionCache)

		primeInitScript(besmanBinDir)
		primeModuleScripts(besmanSrcDir)

		def env = [
				BESMAN_DIR           : besmanDir.absolutePath,
				BESMAN_CANDIDATES_DIR: besmanCandidatesDir.absolutePath,
				BESMAN_OFFLINE_MODE  : "$offlineMode",
				BESMAN_CANDIDATES_API: candidatesApi,
				BESMAN_VERSION       : besmanVersion,
				besman_debug_mode    : Boolean.toString(debugMode),
				JAVA_HOME            : jdkHome
		]

		if (httpProxy) {
			env.put("http_proxy", httpProxy)
		}

		def bashEnv = new BashEnv(baseFolder.absolutePath, env)
		println("\nBesmanBashEnvBuilder: $this")
		println("\nBashEnv: $bashEnv")
		bashEnv
	}

	private prepareDirectory(File target, String directoryName) {
		def directory = new File(target, directoryName)
		directory.mkdirs()
		directory
	}

	private initializeVersionCache(File folder, String version) {
		if (version) {
			new File(folder, "version") << version
		}
	}


	private initializeCandidates(File folder, List candidates) {
		candidates.each { candidate ->
			new File(folder, candidate).mkdirs()
		}
	}

	private initializeCandidatesCache(File folder, List candidates) {
		def candidatesCache = new File(folder, "candidates")
		if (candidates) {
			candidatesCache << candidates.join(",")
		} else {
			candidatesCache << ""
		}
	}

	private initializeBroadcast(File targetFolder, String broadcast) {
		new File(targetFolder, "broadcast") << broadcast
	}

	private initializeConfiguration(File targetFolder, Map config) {
		def configFile = new File(targetFolder, "config")
		config.each { key, value ->
			configFile << "$key=$value\n"
		}
	}

	private primeInitScript(File targetFolder) {
		def sourceInitScript = new File(TEST_SCRIPT_BUILD_DIR, 'besman-init.sh')

		if (!sourceInitScript.exists())
			throw new IllegalStateException("besman-init.sh has not been prepared for consumption.")

		def destInitScript = new File(targetFolder, "besman-init.sh")
		destInitScript << sourceInitScript.text
		destInitScript
	}

	private primeModuleScripts(File targetFolder) {
		for (f in TEST_SCRIPT_BUILD_DIR.listFiles()) {
			if (!(f.name in ['selfupdate.sh', 'install.sh', 'besman-init.sh'])) {
				new File(targetFolder, f.name) << f.text
			}
		}
	}
}
