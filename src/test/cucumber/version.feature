Feature: Version

	Scenario: Show the current version of besman
		Given the internet is reachable
		And the besman version is "3.2.1"
		And an initialised environment
		And the system is bootstrapped
		When I enter "bes version"
		Then I see "BESMAN 3.2.1"
