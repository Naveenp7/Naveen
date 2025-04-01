# Troubleshooting Netlify Deployment Issues

If you encounter dependency conflicts during the build process on Netlify, follow these steps:

1. **Use `--legacy-peer-deps`**:
   Modify the build command in Netlify to:
   ```bash
   npm install --legacy-peer-deps && npm run build
   ```

2. **Check for Updates**:
   Run `npm outdated` to see if any dependencies need updating.

3. **Review Peer Dependencies**:
   Look at the peer dependencies mentioned in the error log and adjust your package versions accordingly.

4. **Test Locally**:
   Before pushing changes to Netlify, test the installation locally with:
   ```bash
   npm install --legacy-peer-deps
   npm run build
   ```

5. **Re-deploy**:
   After making the necessary changes, try redeploying your site on Netlify.

Feel free to reach out if you have any questions or need further assistance!
