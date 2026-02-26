# Code Walkthrough: Jodi Daniel Portfolio Website

*2026-02-26T17:03:57Z by Showboat 0.6.1*
<!-- showboat-id: 371bead2-0eef-4fa7-ab7f-bf0e7021be17 -->

This walkthrough explains the complete codebase for Jodi Daniel's professional portfolio website. The site is a single-page application built as one self-contained HTML file with embedded CSS, deployed via GitHub Actions to sprites.dev. We'll walk through every layer — project structure, HTML document setup, CSS architecture, page content sections, responsive design, and the CI/CD pipeline.

## Project Structure

Let's start by looking at what files exist in the repository.

```bash
find . -type f -not -path './.git/*' -not -name 'walkthrough.md' | sort
```

```output
./.github/workflows/deploy.yml
./.gitignore
./AGENTS.md
./CLAUDE.md
./README.md
./index.html
```

The repo is deliberately minimal:

- **index.html** — The entire website in a single self-contained file (HTML + embedded CSS, no JavaScript)
- **.github/workflows/deploy.yml** — GitHub Actions workflow that auto-deploys to sprites.dev on push
- **README.md** — Project documentation with design notes, deployment instructions, and content overview
- **CLAUDE.md / AGENTS.md** — Instructions for AI coding assistants working on this repo
- **.gitignore** — Standard Visual Studio / Node.js / Python ignore rules

There is no JavaScript, no build step, no external CSS files, and no images (the profile photo is an inline SVG placeholder). Everything the browser needs is in `index.html`.

## The HTML Document: Head Section

The file opens as a standard HTML5 document. Let's look at the document declaration and head section.

```bash
sed -n '1,9p' index.html
```

```output
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jodi Daniel | Digital Health Law & Policy Leader</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;600;700&family=Source+Sans+Pro:wght@300;400;600&display=swap" rel="stylesheet">
```

Key details in the head:

1. **`<!DOCTYPE html>`** — HTML5 document type declaration.
2. **`<html lang="en">`** — Sets the document language to English for accessibility and SEO.
3. **`charset="UTF-8"`** — Ensures proper rendering of special characters.
4. **Viewport meta tag** — `width=device-width, initial-scale=1.0` makes the page responsive on mobile devices by matching the viewport to the device width.
5. **Google Fonts** — Two font families are loaded:
   - **Raleway** (weights 400, 600, 700) — Used for headings, navigation, and section titles. It's a geometric sans-serif with an elegant, professional feel.
   - **Source Sans Pro** (weights 300, 400, 600) — Used for body text. The light weight (300) gives the body copy a clean, airy readability.
6. The `rel="preconnect"` links establish early connections to the Google Fonts CDN, reducing latency when the font CSS is eventually fetched.

## CSS Architecture

All styling is embedded in a single `<style>` block within the head (lines 10–458). There is no external stylesheet. Let's walk through the CSS in logical layers.

### Global Reset and Base Styles

```bash
sed -n '11,28p' index.html
```

```output
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Source Sans Pro', sans-serif;
            font-weight: 300;
            line-height: 1.8;
            color: #474747;
            background: linear-gradient(135deg, #1a3a5c 0%, #2d5a7b 25%, #3d7a9c 50%, #4a8dad 75%, #5ba0be 100%);
            min-height: 100vh;
        }
```

The CSS starts with a universal reset (`* { margin: 0; padding: 0; box-sizing: border-box; }`). This strips all default browser margins/padding and switches to `border-box` sizing so that padding and borders are included within an element's declared width/height — a standard practice that makes layout math predictable.

`scroll-behavior: smooth` on the `html` element enables smooth scrolling when clicking the in-page navigation links (e.g., clicking "Expertise" in the nav smoothly scrolls to that section).

The body sets up:
- **Source Sans Pro at weight 300** as the default font — a light, clean sans-serif
- **Line height of 1.8** — generous spacing for readability
- **A diagonal gradient background** — flowing from dark navy (`#1a3a5c`) through medium blues to a lighter teal (`#5ba0be`), running at 135 degrees. This creates the distinctive blue gradient visible behind the white content cards.
- **`min-height: 100vh`** — ensures the gradient always fills at least the full viewport height

### Animation System

```bash
sed -n '30,53p' index.html
```

```output
        /* Fade-in slide-up animation */
        @keyframes fadeSlideIn {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-in {
            opacity: 0;
            animation: fadeSlideIn 0.8s ease-out forwards;
        }

        .delay-1 { animation-delay: 0.1s; }
        .delay-2 { animation-delay: 0.2s; }
        .delay-3 { animation-delay: 0.4s; }
        .delay-4 { animation-delay: 0.6s; }
        .delay-5 { animation-delay: 0.8s; }
        .delay-6 { animation-delay: 1.0s; }
        .delay-7 { animation-delay: 1.2s; }
```

This is the page's entrance animation system. When the page loads, each section fades in while sliding upward — a common "reveal" pattern:

- **`@keyframes fadeSlideIn`** — Defines the animation: start invisible and 30px below final position, end fully visible at the natural position.
- **`.animate-in`** — Applied to every major section. Sets initial `opacity: 0` (hidden), then runs the animation over 0.8 seconds with `ease-out` timing (fast start, gentle deceleration). The `forwards` fill mode keeps the element in its final state after animating.
- **`.delay-1` through `.delay-7`** — Staggered delays so sections cascade in sequence. The header appears first (0.1s), then the about section (0.2s), expertise (0.4s), experience (0.6s), etc. The delays aren't linear — they use increasing gaps (0.1, 0.2, 0.2, 0.2, 0.2, 0.2) which creates a natural-feeling cascade.

Let's verify which HTML sections use these classes:

```bash
grep -n 'animate-in' index.html
```

```output
42:        .animate-in {
462:        <header class="animate-in delay-1">
467:        <section id="about" class="container animate-in delay-2">
505:        <section id="expertise" class="container animate-in delay-3">
535:        <section id="experience" class="container animate-in delay-4">
571:        <section id="accomplishments" class="container animate-in delay-5">
584:        <section id="education" class="container animate-in delay-6">
605:        <section id="contact" class="container contact-section animate-in delay-7">
624:        <footer class="animate-in delay-7">
```

Every major page section gets the animation. The order is: header (delay-1, 0.1s) → about (delay-2, 0.2s) → expertise (delay-3, 0.4s) → experience (delay-4, 0.6s) → accomplishments (delay-5, 0.8s) → education (delay-6, 1.0s) → contact and footer (both delay-7, 1.2s). The contact section and footer share the same delay since they appear together at the bottom.

### Layout Foundation: Site Wrapper and Containers

```bash
sed -n '55,89p' index.html
```

```output
        .site-wrapper {
            max-width: 74rem;
            margin: 0 auto;
            padding: 2rem;
        }

        header {
            text-align: center;
            padding: 4rem 2rem;
            color: #ffffff;
        }

        header h1 {
            font-family: 'Raleway', sans-serif;
            font-size: 3rem;
            font-weight: 700;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        header .tagline {
            font-size: 1.25rem;
            font-weight: 300;
            opacity: 0.9;
            letter-spacing: 0.05em;
        }

        .container {
            background: #ffffff;
            border-radius: 0.5rem;
            padding: 3rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
        }
```

Three key layout primitives:

1. **`.site-wrapper`** — The outermost content container. `max-width: 74rem` (~1184px) constrains the page to a comfortable reading width. `margin: 0 auto` centers it horizontally. This wrapper sits on top of the gradient background, so the blue gradient is visible on wider screens flanking the content.

2. **`header`** — Rendered directly on the gradient (no white background). White text, centered, with generous 4rem top/bottom padding. The name uses Raleway at 3rem, bold, uppercase with wide letter-spacing (0.15em) for a stately, professional look. The tagline beneath is lighter (weight 300) at slightly reduced opacity (0.9) to create visual hierarchy.

3. **`.container`** — The white card used for every content section. White background, subtle rounded corners (0.5rem), generous internal padding (3rem), and a pronounced drop shadow (`0 10px 40px rgba(0,0,0,0.15)`). The 2rem bottom margin creates consistent spacing between cards. These white cards floating over the blue gradient are the site's core visual motif.

### Section Title Styling

```bash
sed -n '91,102p' index.html
```

```output
        .section-title {
            font-family: 'Raleway', sans-serif;
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            color: #2d5a7b;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #5dd9e8;
            display: inline-block;
        }
```

The `.section-title` class is used on `<span>` elements at the top of each content card ("Areas of Expertise", "Professional Experience", etc.). It's a small, uppercase, heavily letter-spaced label in Raleway bold — a design pattern borrowed from editorial layouts. The teal underline (`border-bottom: 2px solid #5dd9e8`) provides a pop of color. `display: inline-block` is key — it makes the underline only as wide as the text, not the full container width.

## Page Body: Section by Section

Now let's walk through the HTML body, section by section, pairing structure with its styling.

### The Site Wrapper and Header

```bash
sed -n '460,465p' index.html
```

```output
<body>
    <div class="site-wrapper">
        <header class="animate-in delay-1">
            <h1>Jodi Daniel</h1>
            <p class="tagline">Digital Health Law & Policy Leader</p>
        </header>
```

The header is the first thing the user sees — the name "JODI DANIEL" in large uppercase letters over the gradient, with the tagline below in a lighter weight. It's the first element to animate in (delay-1 = 0.1s). No white card here; it renders directly on the gradient background.

### The About / Intro Section

This is the largest and most complex section — it contains a profile image, bio text, and the site navigation.

```bash
sed -n '104,109p' index.html
```

```output
        .intro-section {
            display: grid;
            grid-template-columns: 180px 1fr;
            gap: 2.5rem;
            align-items: start;
        }
```

```bash
sed -n '467,503p' index.html
```

```output
        <section id="about" class="container animate-in delay-2">
            <div class="intro-section">
                <div class="profile-placeholder">
                    <svg class="profile-image" viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg">
                        <rect width="300" height="300" fill="#e8f4f8"/>
                        <circle cx="150" cy="120" r="50" fill="#2d5a7b"/>
                        <ellipse cx="150" cy="280" rx="80" ry="60" fill="#2d5a7b"/>
                        <text x="150" y="320" text-anchor="middle" fill="#5a6a7a" font-family="Raleway, sans-serif" font-size="12">JD</text>
                    </svg>
                </div>
                <div class="intro-text">
                    <h2>Pioneering the Future of Digital Health</h2>
                    <p>
                        Jodi Daniel is a <span class="highlight">nationally recognized leader</span> in digital health law and policy,
                        trusted by healthcare organizations and technology innovators to navigate the complex regulatory landscape
                        of digital health and wellness.
                    </p>
                    <p>
                        With <span class="highlight">over 30 years of experience</span> in healthcare innovation, including 15 years
                        as a lawyer and senior policymaker at the U.S. Department of Health and Human Services (HHS), Jodi brings
                        unparalleled expertise to groundbreaking products and services that raise novel legal, policy, and ethical issues.
                    </p>
                    <p>
                        As one of the <span class="highlight">first digital health lawyers</span> and a founding Director at the
                        Office of the National Coordinator for Health IT (ONC) at HHS, Jodi helped shape the very foundation of
                        digital health regulation in the United States.
                    </p>
                </div>
            </div>
            <nav class="intro-nav">
                <a href="#expertise">Expertise</a>
                <a href="#experience">Experience</a>
                <a href="#accomplishments">Accomplishments</a>
                <a href="#education">Education</a>
                <a href="#contact">Contact</a>
            </nav>
        </section>
```

The about section is a white `.container` card with two parts:

**1. The intro grid** (`.intro-section`) uses CSS Grid with `grid-template-columns: 180px 1fr` — a fixed-width left column for the profile image and a flexible right column for the bio text. The 2.5rem gap provides breathing room.

**The profile placeholder** is an inline SVG rather than an external image file. It draws:
- A light blue rectangle as background (`#e8f4f8`)
- A circle for the head and an ellipse for shoulders (both in `#2d5a7b`)
- The initials "JD" in text (though positioned below the visible area at y=320)

This SVG gets the `.profile-image` class which adds hover effects — on mouseover, it lifts up 3px (`translateY(-3px)`) and deepens its shadow, a subtle interaction cue.

**The bio text** uses `<span class="highlight">` to pick out key phrases in the medium blue color (`#2d5a7b`) with weight 600, making them stand out from the lighter body text.

**2. The navigation bar** (`.intro-nav`) sits below the grid, separated by a top border. It uses flexbox with centered alignment and wrapping for smaller screens. Each link is styled as an uppercase Raleway label that gets a teal bottom border on hover — matching the section title underline pattern for visual consistency. The `#href` anchors link to section IDs within the page, and the `scroll-behavior: smooth` on `html` makes them scroll smoothly.

### The Expertise Section

```bash
sed -n '184,217p' index.html
```

```output
        .expertise-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .expertise-card {
            padding: 1.5rem;
            background: #f8fafc;
            border-radius: 0.5rem;
            border-left: 4px solid #5dd9e8;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .expertise-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }

        .expertise-card h3 {
            font-family: 'Raleway', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            color: #1a3a5c;
            margin-bottom: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .expertise-card p {
            font-size: 0.95rem;
            color: #5a6a7a;
        }
```

```bash
grep -c 'expertise-card' index.html
```

```output
10
```

```bash
grep '<h3>' index.html | head -6
```

```output
                    <h3>Digital Health & AI</h3>
                    <h3>Health Data Privacy</h3>
                    <h3>FDA & Regulatory Strategy</h3>
                    <h3>Telehealth & Remote Care</h3>
                    <h3>Health IT Policy</h3>
                    <h3>Strategic Advisory</h3>
```

The expertise section displays 6 cards in a 2-column CSS Grid (`repeat(2, 1fr)`). Each card has:

- A light gray background (`#f8fafc`) — slightly off-white to differentiate from the container
- A **teal left border** (`4px solid #5dd9e8`) — a visual accent that connects them to the section title underline
- **Hover lift effect** — on mouseover, cards rise 3px and gain a shadow, giving a tactile feel
- The transition is fast (0.25s) for snappy feedback

The 6 practice areas covered are: Digital Health & AI, Health Data Privacy, FDA & Regulatory Strategy, Telehealth & Remote Care, Health IT Policy, and Strategic Advisory. Each card has a bold uppercase title and a brief description paragraph in muted gray (`#5a6a7a`).

### The Experience Timeline

The experience section is the most visually distinctive, using a CSS-only vertical timeline.

```bash
sed -n '219,277p' index.html
```

```output
        .timeline {
            position: relative;
            padding-left: 2rem;
            margin-top: 1.5rem;
        }

        .timeline::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(to bottom, #5dd9e8, #2d5a7b);
        }

        .timeline-item {
            position: relative;
            margin-bottom: 2rem;
            padding-left: 1.5rem;
        }

        .timeline-item::before {
            content: '';
            position: absolute;
            left: -2rem;
            top: 0.5rem;
            width: 12px;
            height: 12px;
            background: #5dd9e8;
            border-radius: 50%;
            border: 3px solid #ffffff;
            box-shadow: 0 0 0 2px #5dd9e8;
        }

        .timeline-item h3 {
            font-family: 'Raleway', sans-serif;
            font-size: 1.1rem;
            font-weight: 700;
            color: #1a3a5c;
            margin-bottom: 0.25rem;
        }

        .timeline-item .org {
            font-weight: 600;
            color: #2d5a7b;
            margin-bottom: 0.5rem;
        }

        .timeline-item .period {
            font-size: 0.85rem;
            color: #8a9aaa;
            margin-bottom: 0.5rem;
        }

        .timeline-item p {
            font-size: 0.95rem;
            color: #5a6a7a;
        }
```

The timeline is built entirely with CSS pseudo-elements — no images or SVG needed:

**The vertical line** (`.timeline::before`) is an absolutely positioned 2px-wide pseudo-element spanning the full height of the timeline container. It uses a gradient from teal to navy (`#5dd9e8` → `#2d5a7b`), subtly darkening as you scroll through the career history.

**The dot markers** (`.timeline-item::before`) are 12px circles positioned on the vertical line. Each dot is:
- Filled with teal (`#5dd9e8`)
- Surrounded by a 3px white border (creating a gap effect)
- Then wrapped in a 2px teal `box-shadow` outline (the "ring" around the ring)

This triple-layer technique (fill → white border → colored shadow) creates a polished "bullseye" dot without any extra HTML elements.

Each timeline item has a clear information hierarchy through CSS:
- **Role title** (h3) — bold, dark navy, 1.1rem
- **Organization** (.org) — semibold, medium blue  
- **Time period** (.period) — small, light gray
- **Description** (p) — regular weight, muted gray

Let's see one of the timeline entries:

```bash
sed -n '538,543p' index.html
```

```output
                <div class="timeline-item">
                    <h3>Partner</h3>
                    <div class="org">Wilson Sonsini Goodrich & Rosati</div>
                    <div class="period">2025 - Present</div>
                    <p>Partner in the Washington, D.C. office, serving as a key member of the Digital Health and Data, Privacy, and Cybersecurity practices.</p>
                </div>
```

Each timeline entry follows the same pattern: a `div.timeline-item` containing an h3 (title), .org div, .period div, and a p (description). There are 5 entries tracing the career from Attorney-Advisor at HHS through to current Partner at Wilson Sonsini.

### The Accomplishments Section

```bash
sed -n '312,333p' index.html
```

```output
        .accomplishments-list {
            list-style: none;
            margin-top: 1.5rem;
        }

        .accomplishments-list li {
            position: relative;
            padding-left: 2rem;
            margin-bottom: 1rem;
            font-size: 1rem;
        }

        .accomplishments-list li::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0.6rem;
            width: 8px;
            height: 8px;
            background: #5dd9e8;
            border-radius: 50%;
        }
```

```bash
sed -n '571,582p' index.html
```

```output
        <section id="accomplishments" class="container animate-in delay-5">
            <span class="section-title">Key Accomplishments</span>
            <ul class="accomplishments-list">
                <li><strong>HIPAA Architect:</strong> Key drafter of the original HIPAA Privacy Rules and Enforcement Rules that govern health data protection nationwide</li>
                <li><strong>Privacy Framework Developer:</strong> Created the Nationwide Privacy and Security Framework for Electronic Exchange of Health Information</li>
                <li><strong>Health IT Standards Pioneer:</strong> Helped develop early standards and certification rules for health information technology</li>
                <li><strong>Consumer Health Champion:</strong> Launched ONC's Consumer e-Health and Health IT Safety programs</li>
                <li><strong>Information Blocking Expert:</strong> Contributed to drafting ONC's landmark information blocking report and regulations</li>
                <li><strong>HITECH Act Implementation:</strong> Helped chart health IT strategies before and after the HITECH Act invested billions in healthcare technology</li>
                <li><strong>Yale Faculty:</strong> Serves as Adjunct Assistant Professor at Yale School of Medicine, educating the next generation of health leaders</li>
            </ul>
        </section>
```

The accomplishments section uses a custom-styled unordered list. The default `list-style` is set to `none`, and custom teal dots are drawn using `::before` pseudo-elements — 8px circles in `#5dd9e8`, absolutely positioned to the left of each list item. This matches the teal accent color used throughout the site (section title underlines, timeline dots, expertise card borders).

Each list item uses a `<strong>` tag for the accomplishment label followed by a colon and description, creating a simple but effective label-value pair pattern.

### The Education Section

```bash
sed -n '279,310p' index.html
```

```output
        .education-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .education-card {
            text-align: center;
            padding: 2rem;
            background: #f8fafc;
            border-radius: 0.5rem;
        }

        .education-card .degree {
            font-family: 'Raleway', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: #2d5a7b;
            margin-bottom: 0.5rem;
        }

        .education-card .field {
            font-weight: 600;
            color: #1a3a5c;
            margin-bottom: 0.25rem;
        }

        .education-card .school {
            font-size: 0.9rem;
            color: #5a6a7a;
        }
```

```bash
sed -n '584,603p' index.html
```

```output
        <section id="education" class="container animate-in delay-6">
            <span class="section-title">Education</span>
            <div class="education-grid">
                <div class="education-card">
                    <div class="degree">J.D.</div>
                    <div class="field">Law</div>
                    <div class="school">Georgetown University Law Center</div>
                </div>
                <div class="education-card">
                    <div class="degree">M.P.H.</div>
                    <div class="field">Public Health</div>
                    <div class="school">Johns Hopkins Bloomberg School of Public Health</div>
                </div>
                <div class="education-card">
                    <div class="degree">B.A.</div>
                    <div class="field">Economics</div>
                    <div class="school">Tufts University</div>
                </div>
            </div>
        </section>
```

The education section uses a responsive CSS Grid with `repeat(auto-fit, minmax(250px, 1fr))` — this is a powerful CSS pattern that automatically creates as many columns as will fit while keeping each at least 250px wide. With 3 cards and enough width, they display as 3 equal columns; on narrower screens, they automatically reflow to 2+1 or single column without any media queries needed.

Each card is center-aligned with:
- **Degree abbreviation** (.degree) — large (1.5rem), bold, in medium blue — the visual anchor
- **Field of study** (.field) — semibold, dark navy
- **School name** (.school) — smaller, muted gray

The three degrees (J.D. from Georgetown, M.P.H. from Johns Hopkins, B.A. from Tufts) are displayed as clean, equal-weight cards.

### The Contact Section

```bash
sed -n '335,378p' index.html
```

```output
        .contact-section {
            text-align: center;
        }

        .contact-section p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
        }

        .contact-links {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .contact-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            background: #2d5a7b;
            color: #ffffff;
            text-decoration: none;
            font-family: 'Raleway', sans-serif;
            font-size: 0.85rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            border-radius: 0.25rem;
            transition: all 0.25s ease;
        }

        .contact-link:hover {
            background: #1a3a5c;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .contact-link svg {
            width: 18px;
            height: 18px;
            fill: currentColor;
        }
```

```bash
sed -n '605,627p' index.html
```

```output
        <section id="contact" class="container contact-section animate-in delay-7">
            <span class="section-title">Connect</span>
            <p>Interested in discussing digital health strategy, regulatory matters, or speaking opportunities?</p>
            <div class="contact-links">
                <a href="https://www.wsgr.com/en/people/jodi-daniel.html" class="contact-link" target="_blank" rel="noopener">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
                    </svg>
                    Wilson Sonsini Profile
                </a>
                <a href="https://www.linkedin.com/in/jodidaniel/" class="contact-link" target="_blank" rel="noopener">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.32 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.79M6.88 8.56a1.68 1.68 0 0 0 1.68-1.68c0-.93-.75-1.69-1.68-1.69a1.69 1.69 0 0 0-1.69 1.69c0 .93.76 1.68 1.69 1.68m1.39 9.94v-8.37H5.5v8.37h2.77z"/>
                    </svg>
                    LinkedIn
                </a>
            </div>
        </section>

        <footer class="animate-in delay-7">
            <p>&copy; 2026 Jodi Daniel. All rights reserved.</p>
        </footer>
    </div>
```

The contact section is center-aligned and contains two button-style links:

**Link buttons** (`.contact-link`) use `inline-flex` to align the inline SVG icon with the text label. They're styled as pill-shaped buttons with:
- Medium blue background (`#2d5a7b`)
- White uppercase text in Raleway
- A hover effect that darkens to navy (`#1a3a5c`), lifts 2px, and adds a shadow

Each link opens in a new tab (`target="_blank"`) with `rel="noopener"` for security (prevents the new page from accessing `window.opener`).

**The SVG icons** are inline — a globe icon for the Wilson Sonsini profile and the LinkedIn logo. Using `fill: currentColor` means the icons automatically inherit the white text color and don't need separate color management.

**The footer** is minimal — just a copyright notice in semi-transparent white text (`rgba(255, 255, 255, 0.7)`) that sits on the gradient background. Links in the footer would use the teal accent color for consistency.

## Responsive Design

The site uses two media query breakpoints to adapt to smaller screens.

```bash
sed -n '396,457p' index.html
```

```output
        @media (max-width: 900px) {
            .expertise-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            header h1 {
                font-size: 2rem;
                letter-spacing: 0.1em;
            }

            header .tagline {
                font-size: 1rem;
            }

            .intro-section {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .profile-placeholder {
                width: 150px;
                margin: 0 auto;
            }

            .profile-image {
                max-width: 150px;
                margin: 0 auto;
            }

            .intro-text h2 {
                font-size: 1.5rem;
            }

            .intro-nav {
                gap: 0.5rem;
            }

            .intro-nav a {
                font-size: 0.7rem;
                padding: 0.4rem 0.6rem;
                letter-spacing: 0.05em;
            }

            .container {
                padding: 1.5rem;
            }

            .section-title {
                font-size: 0.75rem;
            }

            .expertise-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .education-grid {
                grid-template-columns: 1fr;
            }
        }
```

Two breakpoints handle the responsive behavior:

**At 900px and below:**
- The expertise grid collapses from 2 columns to 1 column. This is a "tablet" breakpoint — the cards are still full-width but stack vertically.

**At 768px and below** (mobile):
- **Header** shrinks from 3rem to 2rem with tighter letter-spacing
- **Intro section** switches from 2-column grid (image + text side by side) to single column with centered text. The profile image shrinks to 150px and centers.
- **Navigation links** get smaller (0.7rem), less padding, and tighter letter-spacing to fit on narrow screens
- **Containers** reduce padding from 3rem to 1.5rem — reclaiming space on small screens
- **Section titles** shrink slightly (0.85rem → 0.75rem)
- **Education grid** also goes to single column

Note what's *not* here: the timeline and accomplishments list don't need mobile adjustments because they're already single-column vertical layouts by nature. The education grid also has a fallback built into its CSS (`auto-fit, minmax(250px, 1fr)`) that handles narrowing, but the explicit override to `1fr` ensures clean single-column display on mobile.

## CI/CD Deployment Pipeline

The site is deployed automatically via GitHub Actions to sprites.dev, a hosting service that provides persistent Linux environments. Let's examine the workflow.

```bash
cat .github/workflows/deploy.yml
```

```output
name: Deploy to Sprites.dev

on:
  push:
    branches:
      - main
    paths:
      - 'index.html'
      - '.github/workflows/deploy.yml'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy Website

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to Sprites.dev
        run: |
          echo "Deploying index.html to sprites.dev..."

          # Upload the index.html file
          RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
            -H "Authorization: Bearer ${{ secrets.SPRITES_API_TOKEN }}" \
            -H "Content-Type: application/octet-stream" \
            --data-binary @index.html \
            "https://api.sprites.dev/v1/sprites/jodi-daniel-portfolio/fs/write?path=/home/user/www/index.html")

          HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
          BODY=$(echo "$RESPONSE" | sed '$d')

          echo "Response: $BODY"
          echo "HTTP Status: $HTTP_CODE"

          if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
            echo "Deployment successful!"
            echo "Site URL: https://jodi-daniel-portfolio-blpx4.sprites.app"
          else
            echo "Deployment failed with status $HTTP_CODE"
            exit 1
          fi

      - name: Verify deployment
        run: |
          echo "Verifying site is accessible..."
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://jodi-daniel-portfolio-blpx4.sprites.app")
          if [ "$STATUS" -eq 200 ]; then
            echo "Site is live and accessible!"
          else
            echo "Warning: Site returned status $STATUS"
          fi
```

The deployment workflow has several important design decisions:

**Triggers** (the `on:` block):
- Runs on push to `main` branch, but **only when `index.html` or the workflow itself changes** (via `paths:` filter). This avoids unnecessary deployments when only README or config files change.
- Also supports `workflow_dispatch` — manual triggering from the GitHub Actions UI, useful for redeploying without code changes.

**The deployment step** uses `curl` to PUT the file to the sprites.dev API:
- `--data-binary @index.html` sends the raw file content
- The API token is stored as a GitHub secret (`SPRITES_API_TOKEN`)
- The file is written to `/home/user/www/index.html` on the sprite's filesystem
- The response handling is robust: it captures both the response body and HTTP status code using curl's `-w "\n%{http_code}"` trick, then splits them apart. Any non-2xx response triggers a failure (`exit 1`).

**The verification step** makes a GET request to the live site URL to confirm it returns HTTP 200. This is a basic smoke test — it doesn't check content, just that the server is responding.

Note: The site is served by a Python HTTP server running on port 8080 inside the sprite, with sprites.dev providing HTTPS proxy and the public URL (`jodi-daniel-portfolio-blpx4.sprites.app`).

## Design Patterns Summary

Looking across the entire codebase, several consistent design patterns emerge:

**Color system:** Three colors do all the heavy lifting — dark navy (`#1a3a5c`) for primary text and headings, medium blue (`#2d5a7b`) for links and interactive elements, and teal (`#5dd9e8`) as the accent color. The teal appears in section title underlines, timeline dots, expertise card borders, and accomplishment bullets — tying the whole page together.

**Typography hierarchy:** Raleway (bold, uppercase, letter-spaced) is reserved for headings, labels, and navigation — anything that needs to feel authoritative. Source Sans Pro (light weight) handles all body text — readable and approachable. The contrast between the two creates clear visual hierarchy.

**Micro-interactions:** Hover effects on the profile image, expertise cards, and contact buttons all use the same pattern: `translateY(-Npx)` lift + shadow deepening. This consistency makes the site feel polished without being distracting.

**No JavaScript:** The entire site is pure HTML and CSS. Animations use CSS keyframes, smooth scrolling uses the CSS `scroll-behavior` property, hover effects use CSS transitions. This means zero render-blocking scripts, no framework overhead, and the page loads as fast as the network can deliver a single HTML file.

**Self-contained architecture:** Everything lives in one file. This dramatically simplifies deployment (upload one file), eliminates build steps, avoids cache-busting issues with separate CSS/JS files, and makes the site trivially portable. The tradeoff is that the ~630-line file mixes concerns, but for a single-page portfolio of this scale, the simplicity wins.

## Quick Stats

```bash
echo '--- index.html ---' && wc -l index.html && echo '' && echo '--- CSS (lines 10-458) ---' && echo '449 lines of embedded CSS' && echo '' && echo '--- HTML body (lines 460-629) ---' && echo '170 lines of markup' && echo '' && echo '--- File size ---' && du -h index.html && echo '' && echo '--- deploy.yml ---' && wc -l .github/workflows/deploy.yml
```

```output
--- index.html ---
629 index.html

--- CSS (lines 10-458) ---
449 lines of embedded CSS

--- HTML body (lines 460-629) ---
170 lines of markup

--- File size ---
23K	index.html

--- deploy.yml ---
54 .github/workflows/deploy.yml
```

The entire website is 629 lines and 23KB — roughly 72% CSS, 27% HTML, 0% JavaScript. The deployment pipeline adds 54 lines of YAML. That's it. A complete, animated, responsive professional portfolio in under 700 lines of code.
