# OCost – O(pen)cost Frontend
> **Warning**
> Not production ready. Use at your own risk!

OCost is a super simple frontend for [OpenCost](https://github.com/opencost/opencost)
and includes a deployment template. Kubernetes namespace costs are displayed to
users dependent on their assigned groups in Azure Active Directory (AAD).

## Usage
<details>
  <summary>0. Create an AAD app</summary>

  You **must** sufficient permissions on Azure active directory admin to perform these steps

  0.0. Go to https://portal.azure.com

  0.1. Navigate to `Azure Active Directory` then `App registrations`

  0.2. Click `New registration` and fill in the required fields. The redirect URL will be the apps root URL appended with `/oauth2/callback` e.g. `https://cost.example.com:443/oauth2/callback`

  0.3. On the create applications navigate to `API permissions` and add a Microsoft Graph permission for `Group.ReadAll`

  0.4 Click `Grant admin consent for TENANT`

  0.5 Create a secret by navigating to `Certificates & secrets` and clicking `New client secret`

  0.6 Paste the secret into the `.env` file created from `.env.sample`

  0.7 Find the application ID from the `Overview` pane of the application

  0.8 Add the groups claim to the returned token in the `Token configuration` pane by selecting `Security Groups` then add

</details>

1. Create a `.env` file from `.env.sample` and replace at least the *__CHANGE_ME__* values

2. Create a `ocost_config.yaml` from `ocost.config.yaml`

3. Run
```bash
make dev
```


## Contributing

- Fork this repository and make sure [pre-commit](https://pre-commit.com/index.html) is installed (`pre-commit install`).
- Use the `[issue-number]-[issue-title]` branching convention and favour short-lived branches.
- Raise pull request (PRs) against `main` for review.
- The person creating the PR is responsible for merging and deleting the branch.
