@manual
Feature: Self Update

	Background:
		Given the internet is reachable

	Scenario: Force a Selfupdate
		Given an initialised environment
		And the system is bootstrapped
		When I enter "bes selfupdate force"
		Then I do not see "A new version of BESMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading today..."
		And I see "Updating BESMAN..."
		And I see "Successfully upgraded BESMAN."

	Scenario: Selfupdate when out of date
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "bes selfupdate"
		Then I do not see "A new version of BESMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading today..."
		And I see "Updating BESMAN..."
		And I see "Successfully upgraded BESMAN."

	Scenario: Agree to a suggested Selfupdate
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "bes help" and answer "Y"
		Then I see "A new version of BESMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Successfully upgraded BESMAN."
		And I do not see "Not upgrading today..."

	Scenario: Do not agree to a suggested Selfupdate
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "bes help" and answer "N"
		Then I see "A new version of BESMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Not upgrading today..."
		And I do not see "Successfully upgraded BESMAN."

	Scenario: Automatically Selfupdate
		Given an outdated initialised environment
		And the configuration file has been primed with "besman_auto_selfupdate=true"
		And the system is bootstrapped
		When I enter "bes help"
		Then I see "A new version of BESMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading today..."
		And I see "Successfully upgraded BESMAN."

	Scenario: Do not automatically Selfupdate
		Given an outdated initialised environment
		And the configuration file has been primed with "besman_auto_selfupdate=false"
		And the system is bootstrapped
		When I enter "bes help" and answer "n"
		Then I see "A new version of BESMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Not upgrading today..."
		And I do not see "Successfully upgraded BESMAN."

	Scenario: Bother the user with Upgrade message once a day
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "bes help" and answer "N"
		Then I see "A new version of BESMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Not upgrading today..."
		And I enter "bes help"
		Then I do not see "A new version of BESMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading now..."
		And I do not see "Successfully upgraded BESMAN."

	Scenario: Selfupdate when not out of date
		Given an initialised environment
		And the system is bootstrapped
		When I enter "bes selfupdate"
		Then I see "No update available at this time."
