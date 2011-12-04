Feature: An user can authorize his or her account

  Scenario: Authorize account
    When I authorize my account
    And I type ""
    Then the stdout should contain:
      """
      In a moment, your web browser will open to the Twitter app authorization page.
      Perform the following steps to complete the authorization process:
        1. Sign in to Twitter
        2. Press "Authorize app"
        3. Copy or memorize the supplied PIN
        4. Return to the terminal to enter the PIN

      Press [Enter] to open the Twitter app authorization page.
      """
    And the stdout should contain "https://api.twitter.com/oauth/authorize"
    And the exit status should be 0
