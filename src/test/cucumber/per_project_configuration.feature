Feature: Per-project configuration

	Background:
		Given the internet is reachable
		And an initialised environment

	Scenario: An besman project configuration is generated
		Given the system is bootstrapped
		When I enter "bes env init"
		Then I see ".besmanrc created."

	Scenario: The env command is issued without an besman project configuration present
		Given the system is bootstrapped
		When I enter "bes env"
		Then I see "Could not find .besmanrc in the current directory."
		And I see "Run 'bes env init' to create it."
		And the exit code is 1

	Scenario: The env command is issued with an besman project configuration present
		Given the file ".besmanrc" exists and contains "groovy=2.4.1"
		And the candidate "groovy" version "2.0.5" is already installed and default
		And the candidate "groovy" version "2.4.1" is a valid candidate version
		And the candidate "groovy" version "2.4.1" is already installed but not default
		And the system is bootstrapped
		When I enter "bes env"
		Then I see "Using groovy version 2.4.1 in this shell."
		And the candidate "groovy" version "2.4.1" should be in use
		And the candidate "groovy" version "2.0.5" should be the default
