Feature: A user can get profile information for an account

  Scenario: Get profile information
    When I get profile information for "sferik"
    Then the stdout should contain "Erik Michaels-Ober, since Jul 2007."
    Then the stdout should contain "bio: "
    Then the stdout should contain "location: "
    Then the stdout should contain "web: "
    And the exit status should be 0
