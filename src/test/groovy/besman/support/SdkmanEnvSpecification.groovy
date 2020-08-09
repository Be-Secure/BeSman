package besman.support

import besman.env.BesmanBashEnvBuilder
import besman.stubs.CurlStub

import static besman.support.FilesystemUtils.prepareBaseDir

abstract class BesmanEnvSpecification extends BashEnvSpecification {

	BesmanBashEnvBuilder besmanBashEnvBuilder

	CurlStub curlStub

	File besmanBaseDirectory
	File besmanDotDirectory
	File candidatesDirectory

	String bootstrapScript

	def setup() {
		besmanBaseDirectory = prepareBaseDir()
		curlStub = CurlStub.prepareIn(new File(besmanBaseDirectory, "bin"))
		besmanBashEnvBuilder = BesmanBashEnvBuilder
				.create(besmanBaseDirectory)
				.withCurlStub(curlStub)

		besmanDotDirectory = new File(besmanBaseDirectory, ".besman")
		candidatesDirectory = new File(besmanDotDirectory, "candidates")
		bootstrapScript = "${besmanDotDirectory}/bin/besman-init.sh"
	}

	def cleanup() {
		assert besmanBaseDirectory.deleteDir()
	}
}
