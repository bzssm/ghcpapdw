# History (Project Complete)

## Project Context
- **Status:** ✅ Web Forms frontends delivered (M3)

## Key Learnings
- 2005-era styling (table-based layout)
- ViewState-driven interactions
- Forms auth with shared machineKey


## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

## 2026-05-15 — Team Coordination: Auth Portal Integration
- **Coordination:** expert_webforms WhoAmI.ashx endpoint + legacy_frontend portal UI integration
- **Decisions merged:** WhoAmI.ashx pattern + Auth-aware portal role-based visibility
- **Orchestration:** Logged per-agent and session work in .squad/

## 2026-05-15 — Auth-Aware Portal with Role-Based Link Visibility
- Updated `infrastructure/nginx/html/index.html` to call `/auth/WhoAmI.ashx` on page load
- Unauthenticated users see a "Please log in" message; table of sub-sites is hidden
- Authenticated users see their display name + Logout link in subnav
- Each table row has `data-roles` attribute; JS reveals only rows matching user's roles
- Uses XMLHttpRequest (era-appropriate), `eval()` for JSON parse, `escapeHtml` for XSS safety
- Falls back to unauthenticated view on network error or parse failure

## Learnings
- `data-roles` attribute on table rows is a clean declarative pattern for role-based visibility without hardcoding role checks in JS logic
- Using `eval("(" + text + ")")` for JSON parsing is the IE6-era standard before `JSON.parse` existed
- DOM-based `escapeHtml` (createElement + createTextNode + innerHTML) is the safest pre-library XSS mitigation

