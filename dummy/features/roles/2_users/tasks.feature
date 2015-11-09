@javascript
Feature: Manage tasks

  Scenario: Default
  
    Given a user named "user"
    And I log in as "user"
    And a classified advertisement project
    And I am on the new classified advertisement story page
    When I fill in "Name" with "Dummy"
    And I fill in "Text" with "Dummy"
    And I press "Create Story"
    And I click the new task link
    And I fill in something in the task's name field
    And I fill in "Text" with "Dummy"
    And I fill in something in the vacancy's name field
    And I fill in "Limit" with "3"
    And I select "Berlin" from "Timezone"
    And I fill in "From" with "2999-01-01 00:00:00"
    And I fill in "To" with "9999-12-31 23:59:59"
    And I press "Create Task"
    And I click the sign up task link
    And I confirm all future JS confirm dialogs on this page
    And I click the sign out task link