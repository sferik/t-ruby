Feature: A user can get stats for an account

  Scenario: Get stats
    When I get stats for "testcli"
    Then the stdout should contain "Followers: "
    Then the stdout should contain "Following: "
    And the exit status should be 0
