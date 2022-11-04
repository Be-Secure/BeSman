package besman.steps

import static cucumber.api.groovy.EN.And

And(~/^the file "([^"]+)" exists and contains "([^"]+)"$/) { String filename, String content ->
	new File(besmanBaseEnv, filename).withWriter {
		it.writeLine(content)
	}
}
