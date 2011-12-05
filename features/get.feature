Feature: A user can get a status

  Scenario: Get a status
    When I get "testcli"
    Then the stdout should contain "Testing"
    And the exit status should be 0

  Scenario: Try to get a nonexistent status
    When I get "testcli2"
    Then the stderr should contain "No status found"
