# CLAUDE.md - Agent Guidelines

## Build & Development Commands
- Local development: `bundle exec jekyll serve --livereload`
- Build site: `bundle exec jekyll build`
- Sync council data: `bundle exec ruby _scripts/sync_data.rb --council [COUNCIL_NUMBER] --url [API_URL]`
- Production build: Use `server_build_script.sh` with required parameters

## Code Style Guidelines
- **Jekyll/Liquid**: Follow Jekyll conventions, indent Liquid tags consistently
- **HTML/CSS**: Use Sass (.scss) files in _sass/ directory, 2-space indentation
- **Ruby**: Follow Ruby standard style (2-space indent, snake_case)
- **YAML Front Matter**: Required for all content files (.md), consistent indentation
- **Naming**: Use descriptive, kebab-case for filenames, snake_case for variables
- **Layouts**: Reuse layouts in _layouts/ directory, avoid duplicating HTML
- **Assets**: Store images in assets/images/, SVGs in assets/svg/
- **Components**: Use _includes/ for reusable components
- **Collections**: Store events in _events/, posts in _posts/
- **Error Handling**: Use proper Liquid conditional blocks for error states