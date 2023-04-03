## Manager
The root of the manager repository contains one directory per service, for which preview environments are created. In this case, there's one directory, `hello-service`, which is a module instantiated by the `main.tf` file.

Looking at the hello-service directory we can see multiple things:
- `policies` - Fixtures for policies used by preview environment Stacks.
- `template` - Describes a single hello-service preview environment as a Terraform module. In this case this is a single Spacelift Stack with accompanying environment variables, though you could easily extend this to be i.e. multiple Stacks connected by Trigger Policies. This Stack also has a `spacelift_stack_destructor` attached, which will make sure to destroy all resources of this Stack before deleting it. This way all resources of a preview environment are cleaned up on deletion.
- `environments` - List of active preview environments, one file per preview environment. Each file is just an instantiation of the `template` module.
- `main.tf` - Creates dependencies common to all preview environments, in this case it creates record for the wildcard domain name `*.hello-service.preview-environments.liftspace.net`. Each preview environments AWS Lambda will be accessible through this URL, with the environment ID in place of the wildcard.

For each preview environment there are multiple variables which need to be specified, with the interesting being:
- `code_version` - The version of the artifact zipfile to use.
- `environment` - The ID of the preview environment. Should be reasonably unique. In this case we'll be using 8 character prefixes of the hash of the creator repositories owner, name and pull request number.
- `infra_repository_branch` - Which branch of the infra repo to base the preview environment Stack on. The Stacks also have a Push Policy attached to ignore any other branches, so that they don't create any proposed changes.

The manager Stack based on this repository also has an interesting Trigger Policy attached:
```rego
trigger[stack.id] {
    change := input.run.changes[_]
    change.phase == "apply"
    change.entity.type == "spacelift_environment_variable"
    stack := input.stacks[_]
    sanitized(stack.id) == change.entity.data.values.stack_id
}
```
Whenever it finishes execution, it will trigger any stacks it controls, for which environment variables have been changed. This way, if only the `code_version` for a preview environment changes, which only results in an environment variable change, the Stack representing this preview environment will be triggered.