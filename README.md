# cost-k8s-prototype
> **Warning**
> Not production ready. Use at your own risk!


## Development
0. <details>
  <summary>Create an AAD app</summary>

  You **must** sufficient permissions on Azure active directory admin to perform these steps
  0.0. Go to https://portal.azure.com/#home
  0.1. Navigate to `Azure Active Directory` then `App registrations`
  0.2. Click `New registration` and fill in the required fields. The redirect URL will be the apps root URL appended with `/oauth2/callback` e.g. `https://cost.example.com:443/oauth2/callback`
  0.3. On the create applications navigate to `API permissions` and add a Microsoft Graph permission for `Group.ReadAll`
  0.4 Click `Grant admin consent for TENANT`
  0.5 Create a secret by navigating to `Certificates & secrets` and clicking `New client secret`
  0.6 Paste the secret into the `.env` file created from `.env.sample`
  0.7 Find the application ID from the `Overview` pane of the application
  ```
</details>

1. Create a `.env` file from `.env.sample` and a `opencost.json` containing customized costs

```bash
make dev
```

## 🔗 Links

- https://www.opencost.io/docs/
