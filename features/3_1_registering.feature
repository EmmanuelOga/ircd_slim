@registering
Feature: Registering
  In order to start using the IRC facilities
  As an IRC user
  I want to register myself

  Scenario: 3.1.1 Password message without a password
    When I send "PASS" with:
      | password  |       |
    Then I should receive "err_need_more_params"

  Scenario: 3.1.1 Password message with a password
    When I send "PASS" with:
      | password  | s3cr3t |
    Then I should not receive any message

  Scenario: 3.1.2 Nick message with nick
    When I send "NICK" with:
      | nick      | tony  |
    Then I should not receive any message

  Scenario: 3.1.2 Nick message without nick
    When I send "NICK" with:
      | nick      |       |
    Then I should receive "err_no_nick_name_given"

  Scenario: 3.1.2 Nick message with invalid nick
    When I send "NICK" with:
      | nick      | 1     |
    Then I should receive "err_erroneus_nick_name"

  Scenario: 3.1.3.0  User message w/o user name
    When I send "USER" with:
      | realname | Emmanuel Oga |
    Then I should receive "err_need_more_params"

  Scenario: 3.1.3.1  User message w/o real name
    When I send "USER" with:
      | user      | emmanuel     |
    Then I should receive "err_need_more_params"

  Scenario: 3.1.3.2  User message
    When I send "USER" with:
      | user      | emmanuel     |
      | realname | Emmanuel Oga |
    Then I should not receive any message

  # Scenario: 3.1.4 Oper message

  Scenario: 3.1.5.0 User mode message for not existent nick
    When I send "MODE" with:
      | target | bogus |
    Then I should receive "err_no_such_nick"

  Scenario: 3.1.5.1 User mode message for existent nick
    Given I send "NICK" with:
      | nick      | my_nick |
    When I send "MODE" with:
      | target | my_nick |
    Then I should receive "rpl_u_mode_is"

  Scenario: 3.1.5.2 Setting User mode message
    Given I send "NICK" with:
      | nick | my_nick |
    When I send "MODE" with:
      | target  | my_nick |
      | flags | +o      |
    Then I should receive "rpl_u_mode_is"

  # Scenario: 3.1.6 Service message

  Scenario: 3.1.7 Quit
    Given I send "NICK" with:
        | nick         | my_nick        |
      And I send "USER" with:
        | user         | emmanuel       |
        | realname    | emmanuel       |
    When I send "QUIT" with:
        | quit_message | Gone for lunch |
    Then I should receive "QUIT" with:
        | quit_message | Gone for lunch |
        | prefix       | my_nick!emmanuel@127.0.0.1 |

  Scenario: 3.1.7 Quit when I'm connected to a few channels
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And wilma registered as user "wilma@127.0.0.1" with nick "wilma"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOINs "#SomeChannel"
      And I JOIN "#SomeChannel"
      And wilma JOINs "#SomeOtherChannel"
      And I JOIN "#SomeOtherChannel"
    When I send "QUIT" with:
        | quit_message | Gone for lunch |
    Then fred should receive "QUIT" with:
        | quit_message | Gone for lunch |
        | prefix       | Emmanuel!Emmanuel@127.0.0.1 |
      And wilma should receive "QUIT" with:
        | quit_message | Gone for lunch |
        | prefix       | Emmanuel!Emmanuel@127.0.0.1 |

  # Scenario: 3.1.8 Squit

  Scenario: Registering using password
    When I send "PASS" with:
      | password  | s3cr3t |
      And I send "USER" with:
      | user         | emmanuel       |
      | realname    | Emmanuel       |
      And I send "NICK" with:
      | nick         | EmmanuelOga    |
    Then I should receive messages "001" through "004"

  Scenario: Registering without a password
    When I send "USER" with:
      | user         | emmanuel       |
      | realname    | Emmanuel       |
      And I send "NICK" with:
      | nick         | EmmanuelOga    |
    Then I should receive messages "001" through "004"

  Scenario: Changing the NICK
    Given I send "USER" with:
      | user         | eoga               |
      | realname    | Emmanuel           |
      And I send "NICK" with:
      | nick         | EEE                |
    When I send "NICK" with:
      | nick         | NewNick            |
    Then I should receive "NICK" with:
      | prefix       | EEE!eoga@127.0.0.1 |
      | nick         | NewNick            |
