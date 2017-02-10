# should create a 'router' dc in default namespace
describe command("oc get dc/router -n default --template '{{.metadata.name}}'") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/^router$/) }
end

# dc should have 1 instance (the number of nodes with region=infra label)
describe command('oc get dc/router -n default --template {{.spec.replicas}}') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/^1$/) }
end

# dc should have region=infra nodeSelector
describe command("oc get dc/router -n default --template '{{.spec.template.spec.nodeSelector}}'") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/region:infra/) }
end
