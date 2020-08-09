Feature: Command Line Interop

	Background:
		Given the internet is reachable
		And an initialised environment
		And the system is bootstrapped

	Scenario: Enter bes
		When I enter "bes"
		Then I see "Usage: bes <command> [candidate] [version]"
		And I see "bes offline <enable|disable>"

	Scenario: Ask for help
		When I enter "bes help"
		Then I see "Usage: bes <command> [candidate] [version]"

	Scenario: Enter an invalid Command
		When I enter "bes goopoo grails"
		Then I see "Invalid command: goopoo"
		And I see "Usage: bes <command> [candidate] [version]"

	Scenario: Enter an invalid Candidate
		When I enter "bes install groffle"
		Then I see "Stop! groffle is not a valid candidate."
