# Deployment Guide for Netlify

## Deploying to Netlify

1. **Build the Project**:
   First, you need to build your project to generate the production files. Run the following command in your terminal:
   ```bash
   npm run build
   ```

2. **Create a Netlify Account**:
   - Go to [Netlify](https://www.netlify.com/) and sign up for a free account.

3. **Deploy Your Site**:
   - After logging in, you will be taken to the Netlify dashboard.
   - Click on the "New site from Git" button.
   - Connect your GitHub account and select the repository containing your project.

4. **Configure Build Settings**:
   - In the build settings, set the following:
     - **Branch to deploy**: `main` (or the branch you want to deploy)
     - **Build command**: `npm run build`
     - **Publish directory**: `dist`
   - Click "Deploy site".

5. **Access Your Website**:
   After a few minutes, your website will be available at a unique URL provided by Netlify. You can customize this URL in the site settings.

Feel free to reach out if you have any questions or need further assistance!
