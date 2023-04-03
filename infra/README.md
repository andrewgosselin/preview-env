## Infra
The infra repository creates the actual AWS Lambda and API Gateway resources.

For each PR, it will create a file in the `hello-service/environments` directory, with the `code_version` filled with `latest`, and the `infra_repository_branch` filled with the source branch of the PR. It updates the files on each commit added to the PR, and deletes the file when the Pull Request is closed.