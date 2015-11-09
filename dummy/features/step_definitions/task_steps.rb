When /^I click the new task link$/ do
  find(:xpath, '(//a[@class="btn btn-default new_task_link"])[1]').click
end

When /^I fill in something in the task's name field$/ do
  find(:xpath, ".//*[@name='task[name]']").set('Dummy')
end

When /^I fill in something in the vacancy's name field$/ do
  find(:xpath, ".//*[@name='task[vacancy_attributes][name]']").set('Dummy')
end

When /^I click the sign up task link$/ do
  find(:xpath, '(//a[@class="btn btn-success btn-xs sign_up_task_link"])[1]').click
end

When /^I click the sign out task link$/ do
  find(:xpath, '(//a[@class="btn btn-danger btn-xs sign_out_task_link"])[1]').click
end