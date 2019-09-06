#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export AWS_STUB_DEBUG=/dev/tty
# export JQ_STUB_DEBUG=/dev/tty

@test "Create a new Events rule when one does not exist (schedule expression)" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_FAMILY=hello-world
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION=tests/test.json
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME=my_rule_name
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION="Events-rule-description"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN="arn:aws:iam::12345678910:role/my-events-role"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SCHEDULE_EXPRESSION="cron(* * * ? * *)"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_TARGET_DEFINITION=tests/partial-target-definition.json
  partial_target_definition=$(cat tests/partial-target-definition.json)
  full_target_definition=$(cat tests/full-target-definition.json)
  target_definition_template=$(cat lib/target-definition.json)

  stub jq \
    "'.taskDefinition.taskDefinitionArn' : echo 'arn:aws:ecs:12345678910:us-east-1:task/hello-world'" \
    "'.taskDefinition.revision' : echo 1" \
    "--arg TASK_ARN arn:aws:ecs:12345678910:us-east-1:task/hello-world .TaskDefinitionArn=\$TASK_ARN : echo ${partial_target_definition}" \
    "-s '.[0].Targets[0] + .[1]' ${target_definition_template} '<(echo ${partial_target_definition} : echo ${full_target_definition}"


  stub aws \
    "ecs register-task-definition --family hello-world --container-definitions '{\"json\":true}' : echo '{\"taskDefinition\":{\"revision\":1, \"taskDefinitionArn\":\"arn:aws:ecs:12345678910:us-east-1:task/hello-world\"}}'" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ''" \
    "events put-rule --name my_rule_name --description 'Events-rule-description' --role_arn arn:aws:iam::12345678910:role/my-events-role --schedule_expression 'cron(* * * ? * *)' : echo ok" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ENABLED" \
    "events put-targets --rule my_rule_name --cli-input-json : echo ok" \
    "events list-targets-by-rule --rule my_rule_name --query 'length(Targets[*])' : echo 1"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Events rule created, and target set successfully 🚀"

  unstub aws
  unstub jq
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_IMAGE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_SCHEDULE_EXPRESSION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_BUS_NAME
}

@test "Create a new Events rule when one does not exist (event pattern)" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_FAMILY=hello-world
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION=tests/test.json
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME=my_rule_name
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION="Events-rule-description"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN="arn:aws:iam::12345678910:role/my-events-role"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN="rate(5 minutes)"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_TARGET_DEFINITION=examples/ecs-target.json
  partial_target_definition=$(cat tests/partial-target-definition.json)
  full_target_definition=$(cat tests/full-target-definition.json)
  target_definition_template=$(cat lib/target-definition.json)

  stub jq \
    "'.taskDefinition.taskDefinitionArn' : echo 'arn:aws:ecs:12345678910:us-east-1:task/hello-world'" \
    "'.taskDefinition.revision' : echo 1" \
    "--arg TASK_ARN arn:aws:ecs:12345678910:us-east-1:task/hello-world .TaskDefinitionArn=\$TASK_ARN : echo ${partial_target_definition}" \
    "-s '.[0].Targets[0] + .[1]' ${target_definition_template} '<(echo ${partial_target_definition} : echo ${full_target_definition}"

  stub aws \
    "ecs register-task-definition --family hello-world --container-definitions '{\"json\":true}' : echo '{\"taskDefinition\":{\"revision\":1, \"taskDefinitionArn\":\"arn:aws:ecs:12345678910:us-east-1:task/hello-world\"}}'" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ''" \
    "events put-rule --name my_rule_name --description 'Events-rule-description' --role_arn arn:aws:iam::12345678910:role/my-events-role --event_pattern 'rate(5 minutes)' : echo ok" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ENABLED" \
    "events put-targets --rule my_rule_name --cli-input-json : echo ok" \
    "events list-targets-by-rule --rule my_rule_name --query 'length(Targets[*])' : echo 1"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Events rule created, and target set successfully 🚀"

  unstub aws
  unstub jq
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_IMAGE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_BUS_NAME
}

@test "Create a new Events rule when one does not exist (schedule expression & event pattern)" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_FAMILY=hello-world
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION=tests/test.json
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME=my_rule_name
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION="Events-rule-description"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN="arn:aws:iam::12345678910:role/my-events-role"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN="rate(5 minutes)"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SCHEDULE_EXPRESSION="cron(* * * ? * *)"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_TARGET_DEFINITION=examples/ecs-target.json
  partial_target_definition=$(cat tests/partial-target-definition.json)
  full_target_definition=$(cat tests/full-target-definition.json)
  target_definition_template=$(cat lib/target-definition.json)

  stub jq \
    "'.taskDefinition.taskDefinitionArn' : echo 'arn:aws:ecs:12345678910:us-east-1:task/hello-world'" \
    "'.taskDefinition.revision' : echo 1" \
    "--arg TASK_ARN arn:aws:ecs:12345678910:us-east-1:task/hello-world .TaskDefinitionArn=\$TASK_ARN : echo ${partial_target_definition}" \
    "-s '.[0].Targets[0] + .[1]' ${target_definition_template} '<(echo ${partial_target_definition} : echo ${full_target_definition}"

  stub aws \
    "ecs register-task-definition --family hello-world --container-definitions '{\"json\":true}' : echo '{\"taskDefinition\":{\"revision\":1, \"taskDefinitionArn\":\"arn:aws:ecs:12345678910:us-east-1:task/hello-world\"}}'" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ''" \
    "events put-rule --name my_rule_name --description 'Events-rule-description' --role_arn arn:aws:iam::12345678910:role/my-events-role --event_pattern 'rate(5 minutes)' --schedule_expression 'cron(* * * ? * *)' : echo ok" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ENABLED" \
    "events put-targets --rule my_rule_name --cli-input-json : echo ok" \
    "events list-targets-by-rule --rule my_rule_name --query 'length(Targets[*])' : echo 1"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Events rule created, and target set successfully 🚀"

  unstub aws
  unstub jq
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_IMAGE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_BUS_NAME
}

@test "Skips rule creation if it already exists" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER=my-cluster
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE=my-service
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_FAMILY=hello-world
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION=tests/test.json
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME=my_rule_name
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION="Events-rule-description"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN="arn:aws:iam::12345678910:role/my-events-role"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN="rate(5 minutes)"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SCHEDULE_EXPRESSION="cron(* * * ? * *)"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_TARGET_DEFINITION=examples/ecs-target.json
  partial_target_definition=$(cat tests/partial-target-definition.json)
  full_target_definition=$(cat tests/full-target-definition.json)
  target_definition_template=$(cat lib/target-definition.json | sed -e 's/"/\\"/g')

  stub jq \
    "'.taskDefinition.taskDefinitionArn' : echo 'arn:aws:ecs:12345678910:us-east-1:task/hello-world'" \
    "'.taskDefinition.revision' : echo 1" \
    "--arg TASK_ARN arn:aws:ecs:12345678910:us-east-1:task/hello-world .TaskDefinitionArn=\$TASK_ARN : echo ${partial_target_definition}" \
    "-s '.[0].Targets[0] + .[1]' ${target_definition_template} '<(echo ${partial_target_definition} : echo ${full_target_definition}"

  stub aws \
    "ecs register-task-definition --family hello-world --container-definitions '{\"json\":true}' : echo '{\"taskDefinition\":{\"revision\":1, \"taskDefinitionArn\":\"arn:aws:ecs:12345678910:us-east-1:task/hello-world\"}}'" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ENABLED" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ENABLED" \
    "events put-targets --rule my_rule_name --cli-input-json : echo ok" \
    "events list-targets-by-rule --rule my_rule_name --query 'length(Targets[*])' : echo 1"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Events rule created, and target set successfully 🚀"

  unstub aws
  unstub jq
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_IMAGE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_BUS_NAME
}

@test "Fails if neither schedule expression nor event pattern provided" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER=my-cluster
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE=my-service
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_FAMILY=hello-world
  export BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION=tests/test.json
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME=my_rule_name
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION="Events-rule-description"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN="arn:aws:iam::12345678910:role/my-events-role"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_TARGET_DEFINITION=examples/ecs-target.json

  stub jq \
    "'.taskDefinition.taskDefinitionArn' : echo 'arn:aws:ecs:12345678910:us-east-1:task/hello-world'" \
    "'.taskDefinition.revision' : echo 1"

  stub aws \
    "ecs register-task-definition --family hello-world --container-definitions '{\"json\":true}' : echo '{\"taskDefinition\":{\"revision\":1, \"taskDefinitionArn\":\"arn:aws:ecs:12345678910:us-east-1:task/hello-world\"}}'" \
    "events describe-rule --name my_rule_name --query 'State' --output text : echo ''"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "You must specify either --schedule-expression or --event-pattern"

  unstub aws
  unstub jq
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_TASK_DEFINITION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_IMAGE
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_NAME
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_DESCRIPTION
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENTS_RULE_ROLE_ARN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_PATTERN
  unset BUILDKITE_PLUGIN_ECS_DEPLOY_EVENT_BUS_NAME
}
