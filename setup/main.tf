resource "spacelift_stack" "manager" {
  name = "Demo Preview Environments Manager"

  administrative = true
  autodeploy     = true
  branch         = "master"
  repository     = var.manager_repository

  labels = [
    "destroy_on_delete",
    "demo-preview-environments"
  ]
}

resource "spacelift_policy_attachment" "manager-trigger_policy" {
  stack_id  = spacelift_stack.manager.id
  policy_id = spacelift_policy.manager-trigger_policy.id
}

resource "spacelift_policy" "manager-trigger_policy" {
  name = "Demo Preview Environments Manager Trigger Policy"
  type = "TRIGGER"
  body = file("policies/manager-trigger.rego")
}

resource "spacelift_aws_role" "manager" {
  stack_id = spacelift_stack.manager.id
  role_arn = var.aws_role
}

resource "spacelift_environment_variable" "aws_role" {
  stack_id   = spacelift_stack.manager.id
  name       = "TF_VAR_aws_role"
  value      = var.aws_role
  write_only = false
}

resource "spacelift_environment_variable" "domain_name" {
  stack_id   = spacelift_stack.manager.id
  name       = "TF_VAR_domain_name"
  value      = var.domain_name
  write_only = false
}

resource "spacelift_stack_destructor" "manager" {
  depends_on = [
    spacelift_aws_role.manager,
    spacelift_environment_variable.aws_role,
    spacelift_environment_variable.domain_name,
  ]
  stack_id = spacelift_stack.manager.id
}
