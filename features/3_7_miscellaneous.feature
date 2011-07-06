@miscellaneous
Feature: Miscellaneous messages

  # Scenario: 3.7.1 Kill message

  Scenario: 3.7.2 Ping message
    When I send "PING"
    Then I should receive "PONG" with:
      | server | $server_host |

  # Scenario: 3.7.3 Pong message

  # Scenario: 3.7.4 Error
