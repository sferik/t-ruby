Feature: A user can retweet a Tweet

  Scenario: Retweet a Tweet
    When I retweet the latest Tweet by "sferik" using an authorized profile
    Then the stdout should contain "You have retweeted @sferik's latest status"
    And the exit status should be 0

  Scenario: Try to retweet a nonexistent Tweet
    When I retweet the latest Tweet by "testcli2" using an authorized profile
    Then the stdout should not contain "You have retweeted @testcli2's latest status"
    Then the stderr should contain "No status found"
