Feature: A user can favorite a Tweet

  Scenario: Favorite a Tweet
    When I favorite the latest Tweet by "sferik" using an authorized profile
    Then the stdout should contain "You have favorited @sferik's latest status"
    And the exit status should be 0

  Scenario: Try to favorite a nonexistent Tweet
    When I favorite the latest Tweet by "testcli2" using an authorized profile
    Then the stdout should not contain "You have favorited @testcli2's latest status"
    Then the stderr should contain "No status found"
