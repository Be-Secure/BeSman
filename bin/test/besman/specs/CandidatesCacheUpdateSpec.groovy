package besman.specs

import besman.support.BesmanEnvSpecification

class CandidatesCacheUpdateSpec extends BesmanEnvSpecification {

	static final String CANDIDATES_API = "http://localhost:8080/2"

	static final String BROADCAST_API_LATEST_ID_ENDPOINT = "$CANDIDATES_API/broadcast/latest/id"
	static final String CANDIDATES_ALL_ENDPOINT = "$CANDIDATES_API/candidates/all"

	File candidatesCache

	def setup() {
		candidatesCache = new File("${besmanDotDirectory}/var", "candidates")
		curlStub.primeWith(BROADCAST_API_LATEST_ID_ENDPOINT, "echo dbfb025be9f97fda2052b5febcca0155")
				.primeWith(CANDIDATES_ALL_ENDPOINT, "echo groovy,scala")
		besmanBashEnvBuilder.withConfiguration("besman_debug_mode", "true")
	}

	void "should issue a warning and escape if cache is empty"() {
		given:
		bash = besmanBashEnvBuilder
				.withCandidates([])
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bes version")

		then:
		bash.output.contains('WARNING: Cache is corrupt. BESMAN cannot be used until updated.')
		bash.output.contains('$ bes update')

		and:
		!bash.output.contains("BESMAN 5.0.0")
	}

	void "should issue a warning if cache is older than a month"() {
		given:
		bash = besmanBashEnvBuilder
				.withCandidates(['groovy'])
				.build()

		and:
		candidatesCache.setLastModified(((new Date() - 31) as Date).time)

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bes version")

		then:
		bash.output.contains('We periodically need to update the local cache.')
		bash.output.contains('$ bes update')

		and:
		bash.output.contains('BESMAN 5.0.0')
	}

	void "should log a success message in debug mode when no update needed"() {
		given:
		bash = besmanBashEnvBuilder
				.withCandidates(['groovy'])
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bes version")

		then:
		bash.output.contains('No update at this time. Using existing cache')

		and:
		bash.output.contains('BESMAN 5.0.0')
	}

	void "should bypass cache check if update command issued"() {
		given:
		bash = besmanBashEnvBuilder
				.withCandidates([])
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bes update")

		then:
		bash.output.contains('Adding new candidates(s): groovy scala')

		and:
		candidatesCache.text.trim() == "groovy,scala"
	}
}
