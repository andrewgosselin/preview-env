## Service
The service is code for an AWS Lambda responding with Hello World and the current commit SHA.

Whenever a commit to a non-master branch is pushed, it creates a zipfile with the source code, and uploads it to an S3 bucket with the object name being <commit_sha>.zip.

Whenever a commit to the master branch is pushed, it does the same, but uploads the resulting artifact as latest.zip.

For each PR, it will create a file in the `hello-service/environments` directory, with the `code_version` filled with the head commit SHA of the Pull Request, and the `infra_repository_branch` filled with `master`. It updates the files on each commit added to the PR, and deletes the file when the Pull Request is closed.