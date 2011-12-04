Feature: An user can list his or her accounts

  Scenario: List accounts
    When I list my accounts using an authenticated profile
    Then the stdout should contain:
      """
      testcli
        MYCm5oNXkmaAPachb5HBhw (default)
      """
    And the exit status should be 0
