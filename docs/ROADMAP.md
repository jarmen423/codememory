# codememory Roadmap & Future Vision

This document describes the target state for codememory (v1.0+), modeled after the best practices seen in high-quality single-binary MCP tools.

## Target Value Proposition

codememory — The structural memory engine for AI coding agents.

- Single static binary or lightweight Docker image
- One-line install experience
- Optional embedded graph backend (no Neo4j required)
- 100+ languages via tree-sitter + hybrid LSP
- Dramatic token reduction through graph + semantic search
- Works with Claude, Cursor, Windsurf, Aider, and more

## Key Milestones

### Phase 1 – Distribution (In Progress)
- [x] install.sh (macOS/Linux one-liner)
- [x] GitHub Actions release workflow
- [ ] install.ps1 (Windows)
- [ ] codememory update / uninstall commands
- [ ] First tagged release with binaries + checksums

### Phase 2 – Docker Experience
- Multi-arch Dockerfile (non-root, slim)
- GHCR publishing
- Production docker-compose.yml (codememory + Neo4j)
- docker run examples in README

### Phase 3 – Embedded Backend
- GrafeoDB support (pure Rust, embeddable, Cypher)
- Backend abstraction layer
- codememory init wizard backend selection
- GrafeoDB as default for binary/Docker quick-start

### Phase 4 – Local Embeddings
- Vendored static code embeddings (no external API key required for basic use)
- Local semantic search with hybrid scoring

### Phase 5 – Language Expansion
- 100+ languages via vendored tree-sitter
- Hybrid LSP semantic resolution for top 12-15 languages
- Language support matrix in README

### Phase 6 – Polish & Marketing
- Performance benchmarks and token reduction claims
- Security section (signing, VirusTotal)
- Integration with broader agent-memory-hosted concepts
- Auto-config for 11+ agents
- Team-shared compressed graph artifacts
- Final README refresh to match the target vision

## Success Criteria (v1.0)

- User can install with one command and immediately use it with their agent
- No external database required for basic usage (GrafeoDB path)
- Clear performance claims backed by benchmarks
- Professional distribution and documentation

## Related Projects

- agent-memory-hosted – Broader agent memory system (architecture decisions, cross-domain memory, hosted graphs)
