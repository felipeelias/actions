# actions

Reusable GitHub Actions for [felipeelias](https://github.com/felipeelias) repositories.

## Actions

### create-pull-request

Create a pull request from workspace changes using `git` and `gh`.

```yaml
- uses: felipeelias/actions/create-pull-request@main
  with:
    branch: my-branch
    title: My pull request
```

#### Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `branch` | Yes | | Branch name for the pull request |
| `title` | Yes | | Pull request title |
| `commit-message` | No | `title` | Commit message |
| `body` | No | `""` | Pull request body |
| `add` | No | `"."` | File patterns to stage, space-separated |
| `base` | No | Current branch | Base branch for the pull request |

#### Outputs

| Name | Description |
|------|-------------|
| `pull-request-number` | Number of the pull request (empty if no changes) |
| `pull-request-url` | URL of the pull request (empty if no changes) |

If there are no changes to commit, the action exits successfully without creating a PR.

## License

[MIT](LICENSE)
