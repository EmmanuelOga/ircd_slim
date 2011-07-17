@channels
Feature: Channel Management
  In order to chat with others
  As an IRC user
  I want to know existing channels
  And I want to join channels

  Scenario: 3.2.1 Join message
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
    When I send "JOIN" with:
      | channels         | #SomeNewChannel |
    Then I should receive "JOIN" with:
      | channels         | #SomeNewChannel |
    And I should receive "rpl_topic" with:
        | channel          | #SomeNewChannel |
        | topic            | /\S/            |
    # And I should receive "TOPIC" with:
    #   | channel          | #SomeNewChannel |
    #   | topic            | /\S/            |
      And I should receive "rpl_nam_reply" with:
      | channel          | #SomeNewChannel |
      | nicks_with_flags | Emmanuel        |
      And I should receive "rpl_end_of_names" with:
      | channel          | #SomeNewChannel |
      And I should receive "MODE" with:
      | chan_speaker?    | $true           |
      | prefix           | $server_host    |
      | target           | #SomeNewChannel |

  Scenario: 3.2.2.0 Part message
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeChannel"
    When I send "PART" with:
        | channels      | #SomeChannel                |
    Then I should receive "PART" with:
        | prefix        | Emmanuel!Emmanuel@127.0.0.1 |
        | channels      | #SomeChannel                |
        | part_message  | /\S/                        |

  Scenario: 3.2.2.1 Part message, removing users from channels
    Given Charles registered as user "Charles@127.0.0.1" with nick "Charles"
      And Charles JOINs "#SomeChannel"
    When Charles messages are checked from this point on
      And Charles sends "PART" with:
        | channels  | #SomeChannel |
      And Charles sends "WHO" with:
        | pattern   | #SomeChannel |
    Then Charles should not receive "rpl_who_reply" with:
        | user_nick | Charles      |

  Scenario: 3.2.2.2 Part message for people in the room I'm parting
    Given fred registered as user "fred@127.0.0.1" with nick "fred"
      And wilma registered as user "wilma@127.0.0.1" with nick "wilma"
      And I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And fred JOINs "#SomeChannel"
      And wilma JOINs "#SomeChannel"
      And I JOIN "#SomeChannel"
    When I send "PART" with:
        | channels     | #SomeChannel   |
        | part_message | Gone for lunch |
    Then fred should receive "PART" with:
        | part_message | Gone for lunch |
        | prefix       | Emmanuel!Emmanuel@127.0.0.1 |
      And wilma should receive "PART" with:
        | part_message | Gone for lunch |
        | prefix       | Emmanuel!Emmanuel@127.0.0.1 |

  Scenario: 3.2.3 Channel mode message
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeChannel"
    When I send "MODE" with:
        | target          | #SomeChannel |
        | positive_flags! |              |
        | chan_operator!  |              |
    Then I should receive "324" with:
        | channel         | #SomeChannel |

  Scenario: 3.2.4 Topic message
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
    When I send "TOPIC" with:
        | channel         | #SomeChannel |
    Then I should receive "rpl_topic" with:
        | channel         | #SomeChannel |
        | topic           | /\S/         |

  Scenario: 3.2.4 Setting a topic message
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeChannel"
    When I send "TOPIC" with:
        | channel         | #SomeChannel               |
        | topic           | Best channel in the World! |
    Then I should receive "rpl_topic" with:
        | channel         | #SomeChannel               |
        | topic           | Best channel in the World! |

  # Scenario: 3.2.5 Names message

  Scenario: 3.2.6 List message
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeChannel"
      And I JOIN "#SomeOtherChannel"
    When I send "LIST"
    Then I should receive "322" with:
      | channel | #SomeChannel      |
      And I should receive "322" with:
      | channel | #SomeOtherChannel |

  # Scenario: 3.2.7 Invite message

  # Scenario: 3.2.8 Kick command

  Scenario: Changing a user MODE
    Given I registered as user "Emmanuel@127.0.0.1" with nick "Emmanuel"
      And I JOIN "#SomeChannel"
    When I send "MODE" with:
      | target          | Emmanuel |
      | positive_flags! |          |
      | chan_operator!  |          |
    Then I should receive "221" with:
      | nick            | Emmanuel |
      | flags           | /\S/     |
