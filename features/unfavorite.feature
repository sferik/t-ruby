Feature: A user can unfavorite a Tweet

  Scenario: Unfavorite a Tweet
    When I unfavorite the latest Tweet by "sferik" using an authorized profile
    Then the stdout should contain "You have unfavorited @sferik's latest status"
    And the exit status should be 0

  Scenario: Try to unfavorite a nonexistent Tweet
    When I unfavorite the latest Tweet by "testcli2" using an authorized profile
    Then the stdout should not contain "You have unfavorited @testcli2's latest status"
    Then the stderr should contain "No status found"
