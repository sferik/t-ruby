Feature: A user can list his or her direct messages

  Scenario: List direct messages
    When I list my direct messages using an authorized profile
    Then the stdout should contain "testcli2: Testing"
    And the exit status should be 0
