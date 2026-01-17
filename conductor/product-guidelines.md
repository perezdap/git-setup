# Product Guidelines - Git Environment Setup Tool

## Communication Style
- **Tone:** Supportive, educational, and patient. The scripts should feel like a helpful mentor guiding the user through the process.
- **Clarity:** Use plain English and avoid overly dense technical jargon where possible. When technical terms are necessary (e.g., "SSH key", "PAT"), provide a brief, high-level explanation or a guided path to learn more.
- **Interactivity:** Every significant step should be preceded by a clear explanation and followed by a confirmation prompt.

## User Experience (UX) Principles
- **No Dead Ends:** If a step fails or a prerequisite is missing, the tool must provide a clear "Guided Recovery" path. This includes explaining what went wrong and offering actionable steps to resolve it.
- **Focus & Flow:** Use a step-by-step walkthrough for complex tasks. Present information in bite-sized, manageable pieces to prevent cognitive overload.
- **Safety First:** Always warn users before making irreversible changes (like overwriting existing Git configurations) and provide an option to back up or cancel.

## Visual Presentation (CLI)
- **Formatting:** Use consistent formatting for prompts, warnings, and success messages (e.g., bolding, simple ASCII separators).
- **Progress Visibility:** Provide clear feedback on progress (e.g., "Checking for Git...", "Installing Git (this may take a minute)...").
- **Instructions:** Present instructions for external tasks (like GitHub/GitLab UI actions) as numbered, sequential steps within the terminal.
