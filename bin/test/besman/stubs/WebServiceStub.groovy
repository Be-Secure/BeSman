package besman.stubs

import static com.github.tomakehurst.wiremock.client.WireMock.*

class WebServiceStub {

	static primeEndpointWithString(String endpoint, String body) {
		stubFor(get(urlEqualTo(endpoint)).willReturn(
				aResponse()
						.withStatus(200)
						.withHeader("Content-Type", "text/plain")
						.withBody(body)))
	}

	static primeUniversalHookFor(String phase, String candidate, String version, String platform) {
		primeHookFor(phase, candidate, version, platform, true)
	}

	static primePlatformSpecificHookFor(String phase, String candidate, String version, String platform) {
		primeHookFor(phase, candidate, version, platform, false)
	}

	private static primeHookFor(String phase, String candidate, String version, String platform, boolean universal = true) {
		def hookFile = "hooks/${phase}_hook_${candidate}_${version}_${universal ? 'universal' : platform}.sh"
		stubFor(get(urlEqualTo("/hooks/$phase/$candidate/$version/$platform")).willReturn(
				aResponse()
						.withStatus(200)
						.withHeader("Content-Type", "text/plain")
						.withBodyFile(hookFile)))
	}

	static primeDownloadFor(String host, String candidate, String version, String platform) {
		def binary = (candidate == "java") ? "jdk-${version}-${platform}.tar.gz" : "${candidate}-${version}.zip"
		stubFor(get(urlEqualTo("/broker/download/${candidate}/${version}/${platform}")).willReturn(
				aResponse()
						.withHeader("Location", "${host}/${binary}")
						.withStatus(302)))

		stubFor(get(urlEqualTo("/$binary")).willReturn(
				aResponse()
						.withStatus(200)
						.withHeader("Content-Type", "application/zip")
						.withBodyFile(binary)))
	}

	static primeSelfupdate() {
		stubFor(get(urlEqualTo("/selfupdate?beta=false")).willReturn(
				aResponse()
						.withStatus(200)
						.withHeader("Content-Type", "text/plain")
						.withBodyFile("selfupdate.sh")))
	}
}
