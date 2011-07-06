@basic_workings
Feature: Basics Connection Workings
  In order to start using the IRC facilities
  As an IRC clinet
  I want to connect to the server
  And receive responses

  Scenario: 3.0.1 Connecting
    Given I establish a connection
    When I send a not defined message "TEST"
    Then I should receive "err_unknown_command"
