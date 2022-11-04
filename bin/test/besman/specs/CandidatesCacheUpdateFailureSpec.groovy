package besman.specs

import besman.support.BesmanEnvSpecification

class CandidatesCacheUpdateFailureSpec extends BesmanEnvSpecification {

	static final String CANDIDATES_API = "http://localhost:8080/2"

	static final String BROADCAST_API_LATEST_ID_ENDPOINT = "$CANDIDATES_API/broadcast/latest/id"
	static final String CANDIDATES_ALL_ENDPOINT = "$CANDIDATES_API/candidates/all"

	File candidatesCache

	def setup() {
		candidatesCache = new File("${besmanDotDirectory}/var", "candidates")
		curlStub.primeWith(BROADCAST_API_LATEST_ID_ENDPOINT, "echo dbfb025be9f97fda2052b5febcca0155")
				.primeWith(CANDIDATES_ALL_ENDPOINT, "echo html")
		besmanBashEnvBuilder.withConfiguration("besman_debug_mode", "true")
	}

	void "should not update candidates if error downloading candidate list"() {
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
		!bash.output.contains('Fresh and cached candidate lengths')
	}
}
