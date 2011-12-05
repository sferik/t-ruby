Feature: A user can get the gem version

  Scenario: Get gem version
    When I get the gem version
    Then the stdout should contain a gem version
    And the exit status should be 0
