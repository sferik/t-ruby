Feature: An user can list his or her accounts

  Scenario: List accounts
    When I list my accounts using an authorized profile
    Then the stdout should contain exactly:
      """
      testcli
        MYCm5oNXkmaAPachb5HBhw (default)

      """
    And the exit status should be 0
