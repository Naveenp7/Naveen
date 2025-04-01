# Deployment Guide for GitHub Pages

## Deploying to GitHub Pages

1. **Build the Project**:
   First, you need to build your project to generate the production files. Run the following command in your terminal:
   ```bash
   npm run build
   ```

2. **Create a GitHub Repository**:
   - Go to [GitHub](https://github.com/) and log in to your account.
   - Click on the "+" icon in the top right corner and select "New repository".
   - Name your repository (e.g., `portfolio-website`) and set it to public.
   - Click "Create repository".

3. **Push the Build to GitHub**:
   - Navigate to the `dist` folder where the build files are located.
   - Initialize a new Git repository in the `dist` folder:
     ```bash
     cd dist
     git init
     ```
   - Add the remote repository:
     ```bash
     git remote add origin https://github.com/yourusername/portfolio-website.git
     ```
   - Add all files and commit:
     ```bash
     git add .
     git commit -m "Deploying portfolio website"
     ```
   - Push the files to the `gh-pages` branch:
     ```bash
     git push -u origin master:gh-pages
     ```

4. **Configure GitHub Pages**:
   - Go to your repository on GitHub.
   - Click on "Settings".
   - Scroll down to the "Pages" section.
   - Under "Source", select the `gh-pages` branch and click "Save".

5. **Access Your Website**:
   After a few minutes, your website will be available at:
   ```
   https://yourusername.github.io/portfolio-website/
   ```

Feel free to reach out if you have any questions or need further assistance!
