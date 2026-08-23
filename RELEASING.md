# Releasing

Every archive and the `SHA256SUMS.txt` covering them come from a single CI run on
master. Nothing is built or summed by hand, so a release is that run's artifacts plus a
signature over the sums file.

1. Let the master build finish green. All five jobs, including `checksums`.

2. Download that run's artifacts:

   ```bash
   gh run download <run-id> -D dist
   cd dist
   ```

3. Confirm the sums file matches the archives before signing anything, so the signature
   never certifies a mismatch:

   ```bash
   sha256sum -c SHA256SUMS.txt
   ```

4. Sign the sums file. This is deliberately a local step. A signing key held in CI
   secrets could be used by anyone who compromised the repository, which would leave the
   signature proving nothing beyond what the checksums already prove.

   ```bash
   gpg --armor --detach-sign SHA256SUMS.txt
   ```

5. Create the release as a draft with the archives, the sums file and the signature:

   ```bash
   gh release create <tag> --draft veilminer-* SHA256SUMS.txt SHA256SUMS.txt.asc
   ```

6. Verify the draft the way a user would, then publish:

   ```bash
   gpg --verify SHA256SUMS.txt.asc SHA256SUMS.txt
   sha256sum -c SHA256SUMS.txt
   ```

Signing key: `5C2C FA03 0397 FCD7 63F1  A97B F878 8EFB 40E7 50E5`

If signing fails with an ioctl error, the shell has no tty for the passphrase prompt.
`export GPG_TTY=$(tty)` fixes it.

## A note on Windows antivirus

Defender flags miners on a machine learning heuristic rather than a signature, so a
detection like `Trojan:Win32/Bearfoos.B!ml` is that heuristic firing, not a finding. A
PGP signature does not help here, because Windows does not read PGP. The fixes are an
Authenticode signature on the exe, free for open source through SignPath Foundation, and
a false positive submission to Microsoft. Never pack the binaries with UPX, which makes
the heuristic worse.
