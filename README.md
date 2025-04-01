# Deployment Guide for Portfolio Website

## Deploying to Vercel

1. **Build the Project**:
   Run the following command to build the project:
   ```bash
   npm run build
   ```

2. **Create a Vercel Account**:
   Go to [Vercel](https://vercel.com/) and sign up for a free account.

3. **Import Your Project**:
   - Click on "New Project".
   - Connect your GitHub account and select the repository containing your project.

4. **Configure the Project**:
   - Vercel will automatically detect the framework (Vite) and set the build command to `npm run build`.
   - Ensure the output directory is set to `dist`.

5. **Deploy**:
   - Click "Deploy" to start the deployment process.
   - Once completed, you will receive a live URL for your website.

6. **Verify**:
   - Visit the provided URL to ensure your website is live and functioning correctly.

## Other Hosting Options
- **Netlify**: Drag and drop the `dist` folder into the Netlify dashboard or connect your repository.
- **GitHub Pages**: Push the contents of the `dist` folder to a `gh-pages` branch.

Feel free to reach out if you have any questions or need further assistance!
