Feature: Idempotent Self Update

	Background:
		Given the internet is reachable
		And an initialised environment
		And the system is bootstrapped
		And an available selfupdate

	Scenario: Attempt Self Update on an up to date system
		When I enter "bes selfupdate"
		Then I see "No update available at this time."

	Scenario: Force Self Update on an up to date system
		When I enter "bes selfupdate force"
		Then I see "Successfully upgraded BESMAN."
