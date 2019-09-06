# ECS Scheduled Tasks Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for deploying [Amazon ECS Scheduled Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduling_tasks.html).

* Requires the aws cli tool be installed
* Registers a new task definition based on a given JSON file ([`register-task-definition`](http://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html]))
* Creates a CloudWatch Events rule ([`put-rule`](https://docs.aws.amazon.com/cli/latest/reference/events/put-rule.html))
* Adds the newly-registered task definition as a target for the Events rule ([`put-targets`](https://docs.aws.amazon.com/cli/latest/reference/events/put-targets.html))

## Example

```yml
steps:
  - label: ":ecs: :rocket:"
    concurrency_group: "my-scheduled-task"
    concurrency: 1
    plugins:
      - ecs-scheduled-tasks#v1.2.0:
          task-family: "my-task-family"
          task-definition: "examples/hello-world.json"
          events-rule-name: "my-events-rule"
          events-rule-role: "arn:aws:iam::123456789012:role/my-events-rule-role"
          events-target-definition: "examples/ecs-target.json"
```

## Options

### `task-family`

The name of the task family.

Example: `"my-task"`

### `task-definition`

The file path to the ECS task definition JSON file.

Example: `"examples/hello-world.json"`

### `target-definition`

The file path to the Events rule target definition JSON file.

Example: `"examples/ecs-target.json"`

### `events-rule-name`

The name of the CloudWatch Events rule to create.

Example: `"my-events-rule"`

### `events-rule-role`

The IAM role used to invoke the targets of the Events rule.

### `schedule-expression` (optional)

The [AWS schedule expression](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html) to use in the Events rule.

Example: `"cron(* * * ? * *)"`

You must specify either a `schedule-expression` or `event-pattern` when configuring your scheduled task.

### `event-pattern` (optional)

The [AWS event pattern](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html) to use in the Events rule, defined in a JSON file.

Example: `"examples/event-pattern.json"`

You must specify either a `schedule-expression` or `event-pattern` when configuring your scheduled task.

### `events-rule-description` (optional)

A text description for the Events rule.

### `task-role` (optional)

An IAM ECS Task Role to assign to tasks.
Requires the `iam:PassRole` permission for the ARN specified.

### `execution-role` (optional)

The Execution Role ARN used by ECS to pull container images and secrets.

Example: `"arn:aws:iam::012345678910:role/execution-role"`

Requires the `iam:PassRole` permission for the execution role.

## AWS Roles

At a minimum this plugin requires the following AWS permissions to be granted to the agent running this step:

```yml
Policy:
  Statement:
  - Action:
    - ecs:RegisterTaskDefinition
    - events:DescribeRules
    - events:PutRule
    - events:PutTargets
    Effect: Allow
    Resource: '*'
```

## Developing

To run the tests:

```bash
docker-compose run tests
```

## License

MIT (see [LICENSE](LICENSE))
