@sending_messages
Feature: Sending messages

  Scenario: 3.3.1 Privmsg to a channel
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOIN "#SomeChannel"
      And I JOIN "#SomeChannel"
    When I send "PRIVMSG" with:
      | target | #SomeChannel |
      | body   | Hello World! |
    Then fred should receive "PRIVMSG" with:
      | prefix | Emmanuel!Emmanuel@127.0.0.1 |
      | target | #SomeChannel |
      | body   | Hello World! |
      And I should not receive "PRIVMSG"

  Scenario: 3.3.1 Privmsg to a user
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
    When I send "PRIVMSG" with:
      | target | fred                        |
      | body   | Hello Fred!                 |
    Then fred should receive "PRIVMSG" with:
      | prefix | Emmanuel!Emmanuel@127.0.0.1 |
      | target | fred                        |
      | body   | Hello Fred!                 |
      And I should not receive "PRIVMSG"

  Scenario: 3.3.1 Privmsg to a channel after nick change.
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOIN "#SomeChannel"
      And I JOIN "#SomeChannel"
      And I send "PRIVMSG" with:
       | target | #SomeChannel |
       | body   | Hello World! |
      And I send "NICK" with:
       | nick      | Gustav  |
    When I send "PRIVMSG" with:
       | target | #SomeChannel |
       | body   | This is from Gustav! |
    Then fred should receive "PRIVMSG" with:
       | prefix | Gustav!Emmanuel@127.0.0.1 |
       | target | #SomeChannel              |
       | body   | This is from Gustav!      |
      And fred should receive "NICK" with:
       | prefix | Emmanuel!Emmanuel@127.0.0.1 |
       | nick   | Gustav                      |

  Scenario: 3.3.2 Notice to a channel
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And fred JOIN "#SomeChannel"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeChannel"
    When I send "NOTICE" with:
      | target | #SomeChannel |
      | body   | Hello World! |
    Then fred should receive "NOTICE" with:
      | prefix | Emmanuel!Emmanuel@127.0.0.1 |
      | target | #SomeChannel |
      | body   | Hello World! |
      And I should not receive "NOTICE"

  Scenario: 3.3.1 Notice to a user
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOIN "#SomeChannel"
      And I JOIN "#SomeChannel"
    When I send "NOTICE" with:
      | target | fred         |
      | body   | Hello World! |
    Then fred should receive "NOTICE" with:
      | prefix | Emmanuel!Emmanuel@127.0.0.1 |
      | target | fred         |
      | body   | Hello World! |
      And I should not receive "NOTICE"

