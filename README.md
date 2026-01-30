# Jodi Daniel Portfolio Website

A professional portfolio website for Jodi Daniel, a nationally recognized leader in digital health law and policy.

**Live Site:** https://jodi-daniel-portfolio-blpx4.sprites.app

## Project Structure

```
.
├── index.html              # Single-page portfolio website
├── .github/
│   └── workflows/
│       └── deploy.yml      # CI/CD workflow for automatic deployment
└── README.md               # This file
```

## Design

### Inspiration
The design is inspired by [lisabari.com](https://lisabari.com/), featuring:
- Modern gradient background (blue tones)
- Clean typography with Raleway and Source Sans Pro fonts
- Subtle fade-in-while-sliding-up animations on page load
- White card containers with shadow effects

### Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Dark Navy | `#1a3a5c` | Headings, primary text |
| Medium Blue | `#2d5a7b` | Links, highlights |
| Teal Accent | `#5dd9e8` | Borders, hover states |
| Light Gray | `#f8fafc` | Card backgrounds |
| White | `#ffffff` | Main containers |

### Typography
- **Headers:** Raleway (600-700 weight, uppercase with letter-spacing)
- **Body:** Source Sans Pro (300 weight for light, readable text)

### Animations
Elements use the `animate-in` class with staggered delays (`delay-1` through `delay-7`):
- Animation: fade in while sliding up 30px
- Duration: 0.8s ease-out
- Delays range from 0.1s to 1.2s for cascading effect

### Responsive Breakpoints
- **> 900px:** 2-column expertise grid
- **≤ 900px:** Single-column expertise grid
- **≤ 768px:** Full mobile layout (centered content, smaller fonts)

## Deployment

### Hosting
The site is hosted on [sprites.dev](https://sprites.dev), a service that provides persistent Linux environments with HTTP proxy.

- **Sprite Name:** `jodi-daniel-portfolio`
- **URL:** https://jodi-daniel-portfolio-blpx4.sprites.app
- **Web Server:** Python HTTP server on port 8080

### Manual Deployment
```bash
# Upload index.html to the sprite
curl -X PUT \
  -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @index.html \
  "https://api.sprites.dev/v1/sprites/jodi-daniel-portfolio/fs/write?path=/home/user/www/index.html"
```

### CI/CD (GitHub Actions)
Automatic deployment is configured via `.github/workflows/deploy.yml`:
- **Triggers:** Push to `main`/`master` when `index.html` changes
- **Manual:** Can be triggered via GitHub Actions UI

**Required Secret:**
Add `SPRITES_API_TOKEN` to your repository secrets (Settings > Secrets and variables > Actions).

## Content Sections

1. **Header** - Name and tagline with gradient background
2. **About/Intro** - Profile placeholder, bio text, and navigation links
3. **Expertise** - 6 cards covering practice areas (Digital Health & AI, Health Data Privacy, FDA & Regulatory Strategy, Telehealth, Health IT Policy, Strategic Advisory)
4. **Experience** - Timeline of professional history
5. **Accomplishments** - Key career achievements (HIPAA architect, etc.)
6. **Education** - J.D., M.P.H., and B.A. credentials
7. **Contact** - Links to WSGR profile and LinkedIn

## Maintenance

### Updating Content
Edit `index.html` directly. The site is a single self-contained HTML file with embedded CSS.

### Updating Styles
All CSS is in the `<style>` block in the `<head>`. Key sections:
- Lines 30-53: Animation keyframes and delay classes
- Lines 104-142: Intro section layout
- Lines 184-213: Expertise grid and cards
- Lines 376-437: Responsive breakpoints

### Adding New Sections
1. Add a new `<section class="container animate-in delay-N">` in the body
2. Include in navigation by adding a link in `.intro-nav`
3. Increment delay class for proper animation sequencing

## About Jodi Daniel

Jodi Daniel is a partner at Wilson Sonsini Goodrich & Rosati (WSGR) with over 30 years of experience in healthcare innovation. Key highlights:

- **Founding Director** of the Office of Policy at ONC (Office of the National Coordinator for Health IT) at HHS
- **Key drafter** of original HIPAA Privacy Rules and Enforcement Rules
- **Education:** J.D. (Georgetown), M.P.H. (Johns Hopkins), B.A. in Economics (Tufts)
- **Prior roles:** Partner at Crowell & Moring, Senior Counsel for Health IT at HHS

## Resources

- [Wilson Sonsini Profile](https://www.wsgr.com/en/people/jodi-daniel.html)
- [LinkedIn](https://www.linkedin.com/in/jodidaniel/)
- [sprites.dev Documentation](https://docs.sprites.dev)
