Feature: A user can list his or her timeline

  Scenario: List timeline
    When I list my timeline using an authorized profile
    Then the stdout should contain "testcli: Testing"
    And the exit status should be 0
