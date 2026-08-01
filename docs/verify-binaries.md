# GitHub Build Provenance Attestation

TargetBridge release binaries are cryptographically signed using **GitHub
Artifact Attestations** (built on Sigstore). This provides a secure,
tamper-proof software supply chain by enabling anyone to verify that the
distributed release ZIP archives were built directly inside our official
GitHub Actions pipeline from the authentic source code.

---

## How It Works

During the release build process, GitHub Actions dynamically requests a
short-lived cryptographic identity token from the GitHub OIDC provider and
signs the build artifacts. The signed attestations are stored in Sigstore's
public transparency log, creating a cryptographically verifiable link between
the source code and the compiled release binaries.

---

## Verifying Release Binaries

To verify that a downloaded TargetBridge release binary is authentic and has
not been tampered with or built from a malicious fork, you can use the
**GitHub CLI (`gh`)**.

### Prerequisites

1. Install the GitHub CLI: `brew install gh`

2. Log in to your GitHub account (optional but recommended):
   ```bash
   gh auth login
   ```

### Verification Command

Run the `gh attestation verify` command on the downloaded ZIP file, specifying
the official repository owner and name:

```bash
gh attestation verify "/path/to/TargetBridge-Intel-Sender-x86_64.zip" --repo "preggocl/targetbridge-intel"
```

### Expected Successful Output

If the binary is authentic and was built by the official TargetBridge
pipeline, the command will output a confirmation similar to the following:

```text
Loaded 1 attestation for TargetBridge-Intel-Sender-x86_64.app.zip
✓ Verified 1 attestation
✓ Deposited in public transparency log
✓ Signed by GitHub Actions
✓ Originated from preggocl/targetbridge-intel (ref: refs/tags/v3.3.0-intel.1)
```

> [!IMPORTANT]
> This command only succeeds after the Intel fork publishes a release through
> a GitHub Actions workflow configured to generate artifact attestations.
> Locally built test packages are not attested.
>
> If verification fails, it indicates that the file was either modified after
> compilation, generated outside the official GitHub Action runners, or
> uploaded from an unauthorized fork. Do not run unverified binaries.
