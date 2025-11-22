# Robot Vision AI - Learning Project

A hands-on learning journey to understand AI, machine learning, computer vision, and robotics by building an autonomous voice-controlled robot from scratch.

**Repository:** [github.com/MichaelHBaker/ai](https://github.com/MichaelHBaker/ai)

---

## 📌 Context Transfer Protocol (For Claude)

**Last Updated:** 2025-11-21
**Current Phase:** Phase 0 - Sensor & Camera Learning (Hardware Acquisition)
**Status:** HSV-bounded stereo vision completed (stable hybrid version).

### Collaboration Workflow

**Two Claude Instances:**
- **Web Claude** (claude.ai) - Conversations, planning, research, broader context
- **VS Code Claude** - Code development, file editing, testing, implementation

**CRITICAL RULE: NO CODE GENERATION WITHOUT EXPLICIT REQUEST**
Neither Claude instance should generate, write, or output code unless the user explicitly asks for it. This applies to:
- Web Claude: Do not create code files or write implementation code unprompted
- VS Code Claude: Do not modify files or generate code without being asked

**Which Claude to Ask?**

Ask **Web Claude** for:
- "Should I...?" - Exploring approaches and trade-offs
- "Would it make sense to...?" - Architectural decisions
- "What's the best approach for...?" - Planning and strategy
- "How do X and Y compare?" - Conceptual analysis
- "Why isn't this working as expected?" - Diagnostic discussion

Ask **VS Code Claude** for:
- "Implement X" - Writing/modifying code
- "Fix this error" - Debugging and troubleshooting
- "Run this test" - Executing experiments
- "Commit these changes" - Git operations

**Update Protocol:**
1. At end of each session, update `session_notes.md` with brief bullet points.
2. Update `README.md` only if architecture or status changes significantly.
3. Commit and push to GitHub.
4. Next session: Upload README + SESSION_NOTES to Claude.

**File Access:** Web Claude can fetch files directly from GitHub using paths listed in session notes: