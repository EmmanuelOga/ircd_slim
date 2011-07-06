@user_base_queries
Feature: User based queries

  Scenario: 3.6.1.0  Who query with a channel as pattern
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOIN "#SomeChannel"
      And I JOIN "#SomeChannel"
    When I send "WHO" with:
      | pattern   | #SomeChannel |
    Then I should receive "rpl_who_reply" with:
      | user_nick | fred         |
      | channel   | #SomeChannel |
      And I should receive "rpl_who_reply" with:
      | user_nick | Emmanuel     |
      | channel   | #SomeChannel |

  Scenario: 3.6.1.1  Who query with a normal pattern
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOIN "#SomeChannel"
      And I JOIN "#SomeChannel"
    When I send "WHO" with:
      | pattern | *re* |
    Then I should receive "rpl_who_reply" with:
      | user_nick | fred |

  Scenario: 3.6.2  Whois query
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeNewChannel"
      And I JOIN "#SomeOtherChannel"
    When I send "WHOIS" with:
      | pattern | Emmanuel |
    Then I should receive "311" with:
      | nick      | Emmanuel    |
      | user      | Emmanuel    |
      And I should receive "312" with:
      | nick      | Emmanuel    |
      | server    | /\S/        |
      | info      | /\S/        |
      And I should receive "318"
      And I should receive "319" with:
      | channels | /#SomeNewChannel/    |
      | channels | /#SomeOtherChannel/  |
      And I should receive "319" with:
      | user    | Emmanuel    |

  # Scenario: 3.6.3  Whowas
