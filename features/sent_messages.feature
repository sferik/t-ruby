Feature: A user can list his or her sent messages

  Scenario: List sent messages
    When I list my sent messages using an authorized profile
    Then the stdout should contain "testcli2: Testing"
    And the exit status should be 0
