module CandidatureFactoryMethods
  def set_candidature_defaults(attributes)
    unless attributes[:resource] || attributes[:resource_id] || !@me
      attributes[:resource_type] ||= 'User'
      attributes[:resource_id] ||= @me.id 
    end
    
    attributes[:vacancy_id] ||= Vacancy.last.id unless attributes[:vacancy_id] || Vacancy.all.none?
    attributes[:offeror_id] ||= Vacancy.find(attributes[:vacancy_id]).project.user_id if attributes[:vacancy_id]
  end
  
  def new_candidature(name, state = nil)
    attributes = { name: name }
    attributes[:state] = state if state
    
    set_candidature_defaults(attributes)
    
    @candidature = FactoryGirl.create(:candidature, attributes) 
    
    @candidature.reload
  end
end

World(CandidatureFactoryMethods)

Given /^a candidature named "([^\"]*)"$/ do |name|
  new_candidature(name)
end

Given /^a candidature named "([^\"]*)" with state "([^\"]*)"$/ do |name,state|
  new_candidature(name, state)
end

Then /^I should see the following candidatures:$/ do |expected_table|
  rows = find('table').all('tr')
  table = rows.map { |r| r.all('th,td').map { |c| c.text.strip } }
  expected_table.diff!(table)
end
