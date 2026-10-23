---
applyTo: '**/*.{js,jsx,ts,tsx,mjs,cjs,py,go,java,kt,kts,cs,rb,php,rs,swift,scala,sql,html,css,scss,sass,vue,svelte}'
description: 'OWASP-aligned application security standards for backend/frontend source files, including anti-pattern detection and corrective coding guidance.'
---

# Security Standards

Write code that avoids the anti-patterns below and flag them when reviewing or editing existing code. Each rule lists severity and the OWASP 2025 category (A01 Broken Access Control, A02 Misconfiguration, A03 Supply Chain, A04 Cryptographic Failures, A05 Injection, A06 Insecure Design, A07 Authentication Failures, A08 Integrity Failures, A09 Logging/Alerting Failures, A10 Exceptional Conditions).

**Severity:** CRITICAL = exploitable, fix before merge. IMPORTANT = significant risk, fix soon. SUGGESTION = defense in depth.

## Injection

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| I1 | SQL built by string concatenation or interpolation | Parameterized queries | CRITICAL | A05 |
| I2 | NoSQL operator injection (`{ "$gt": "" }` from request body) | Cast/validate input types; never pass request objects into queries | CRITICAL | A05 |
| I3 | Shell commands built from user input | Use `execFile`/`spawn` (async) with an argument array, no shell, `--` before user args, `timeout`, `maxBuffer`, and an allowlist | CRITICAL | A05 |
| I4 | Unsanitized HTML rendering (`dangerouslySetInnerHTML`, `[innerHTML]`, `bypassSecurityTrust*`, `v-html`) | Prefer text interpolation; otherwise sanitize with DOMPurify | CRITICAL | A05 |
| I5 | SSRF via user-controlled URLs | Allow only `https`, allowlist hostnames, resolve all A/AAAA records and reject private/loopback/link-local/IPv4-mapped IPs, pin the resolved IP, `redirect: 'error'` | CRITICAL | A01 |
| I6 | Path traversal in file access | `path.resolve` against a base directory and verify the result starts with `base + path.sep` | CRITICAL | A01 |
| I7 | User input used as template source | Use predefined templates; user input only as data | CRITICAL | A05 |
| I8 | XXE | Disable external entities and entity processing in XML parsers | CRITICAL | A05 |

## Authentication

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| AU1 | `jwt.verify` without an `algorithms` allowlist (`alg:none`) | Enforce e.g. `algorithms: ['RS256']` | CRITICAL | A07 |
| AU2 | `jwt.sign` without expiry | Short-lived tokens (`expiresIn: '15m'`) | CRITICAL | A07 |
| AU3 | Tokens in `localStorage` | httpOnly, secure, SameSite cookies set by the server | IMPORTANT | A07 |
| AU4 | Plaintext or fast hashes (MD5/SHA-1/SHA-256) for passwords | Argon2id (preferred) or bcrypt cost >= 12 | CRITICAL | A04 |
| AU5 | No brute-force protection on login/register/reset | Rate limiting (e.g. 5 per 15 min) | CRITICAL | A07 |
| AU6 | Session not regenerated on login | `req.session.regenerate` on login; invalidate other sessions on password change | IMPORTANT | A07 |
| AU7 | OAuth without `state` | Random `state` stored in session and verified on callback | CRITICAL | A07 |
| AU8 | Public OAuth clients without PKCE | PKCE with S256 | IMPORTANT | A07 |

## Authorization

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| AZ1 | New endpoint without auth middleware | `authenticate` + `authorize(role)` on every route | CRITICAL | A01 |
| AZ2 | Client-side-only authorization | Frontend guards are UX only; always check on the server | CRITICAL | A01 |
| AZ3 | IDOR | Verify the resource belongs to the caller; return 404 otherwise | CRITICAL | A01 |
| AZ4 | Mass assignment (`update(req.body)`) | Pick allowed fields explicitly | CRITICAL | A01 |
| AZ5 | Role/permissions accepted from input | Ignore client-supplied `role`/`isAdmin`; set server-side | CRITICAL | A01 |
| AZ6 | No re-authentication for sensitive actions | Require current password for deletion or email change | IMPORTANT | A01 |

## Secrets

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| S1 | Hardcoded keys/tokens | Environment variables or a secret manager | CRITICAL | A04 |
| S2 | `.env`, `*.pem`, `*.key` committed | Add to `.gitignore`; check `git ls-files .env` is empty | CRITICAL | A04 |
| S3 | Server secrets exposed to the client (`NEXT_PUBLIC_*`, Angular `environment.ts`) | Keep secrets server-side only | CRITICAL | A02 |
| S4 | Default credentials in config | Validated env vars (e.g. zod schema) | CRITICAL | A02 |
| S5 | Secrets echoed in CI/CD logs | Masked secrets; never print secret env vars | IMPORTANT | A09 |
| S6 | Stack traces/SQL in error responses | Generic error to client, details only in logs; detail only in development | IMPORTANT | A10 |

## Headers

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| H1 | Missing Content-Security-Policy | Define a CSP | IMPORTANT | A02 |
| H2 | CSP with `unsafe-inline`/`unsafe-eval` | Nonce-based: `script-src 'self' 'nonce-{SERVER_GENERATED}'` | IMPORTANT | A02 |
| H3 | Missing HSTS | `max-age=31536000; includeSubDomains; preload` | IMPORTANT | A02 |
| H4 | Missing `X-Content-Type-Options` | `nosniff` | IMPORTANT | A02 |
| H5 | Missing `X-Frame-Options` | `DENY` and CSP `frame-ancestors 'none'` | IMPORTANT | A02 |
| H6 | Permissive Referrer-Policy | `strict-origin-when-cross-origin` | SUGGESTION | A02 |
| H7 | Missing Permissions-Policy | `camera=(), microphone=(), geolocation=(), payment=()` | SUGGESTION | A02 |
| H8 | CORS wildcard with credentials | Explicit origin allowlist | CRITICAL | A02 |

## Frontend

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| FE1 | Unsanitized HTML rendering | DOMPurify (see I4) | CRITICAL | A05 |
| FE2 | `eval` or dynamic code from user input | Structured parsers such as `JSON.parse` | CRITICAL | A05 |
| FE3 | `postMessage` handler without origin check | Compare `event.origin` to a trusted origin | IMPORTANT | A01 |
| FE4 | Prototype pollution via merging user objects | Filter `__proto__`/`constructor` keys before merging | IMPORTANT | A05 |
| FE5 | Open redirect | Allow relative paths only (`/x`, not `//x`) | IMPORTANT | A01 |
| FE6 | Sensitive data in `localStorage` | httpOnly cookies | IMPORTANT | A07 |
| FE7 | Missing CSRF protection on state-changing requests | Synchronizer or double-submit token, or SameSite cookies | IMPORTANT | A01 |
| FE8 | Client-only input validation | Always validate server-side too (zod/joi/class-validator) | IMPORTANT | A05 |

## Dependencies

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| D1 | Known vulnerable dependency | `npm audit --audit-level=high` (or equivalent) passes | CRITICAL | A03 |
| D2 | Lockfile out of sync | `npm ci` succeeds | IMPORTANT | A08 |
| D3 | Typosquatting | Review new dependency names | IMPORTANT | A03 |
| D4 | Postinstall scripts in new dependencies | Review before adding | IMPORTANT | A03 |
| D5 | Unpinned (`*`, `latest`) production versions | Pin versions | SUGGESTION | A03 |

## API

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| AP1 | Endpoint without rate limiting | Add rate limiting | IMPORTANT | A05 |
| AP2 | GraphQL without depth/complexity limits | `graphql-depth-limit`; introspection off in production | IMPORTANT | A05 |
| AP3 | Upload without type/size checks | Size limit plus MIME allowlist | IMPORTANT | A05 |
| AP4 | Webhook without signature verification | Verify HMAC/signature | CRITICAL | A08 |
| AP5 | API exposing internal info (stack, SQL) | Generic errors | IMPORTANT | A10 |
| AP6 | No request body size limit | e.g. `express.json({ limit: '100kb' })` | IMPORTANT | A05 |

## AI/LLM

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| AI1 | User input concatenated into prompts | Separate system and user messages | CRITICAL | A05 |
| AI2 | LLM output passed to SQL/shell/HTML unchecked | Treat as untrusted input: parameterize, escape, sanitize | CRITICAL | A05 |
| AI3 | LLM output used without schema validation | Validate with Zod/JSON Schema; reject mismatches | IMPORTANT | A08 |

## Logging

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| L1 | Security events not logged | Log auth failures, access denied, rate-limit hits, validation failures, password changes | IMPORTANT | A09 |
| L2 | Sensitive data in logs | Redact passwords, tokens, PII (e.g. pino `redact`) | CRITICAL | A09 |
| L3 | No trace/correlation IDs | Add correlation IDs | SUGGESTION | A09 |
| L4 | Log injection via string concatenation | Structured (JSON) logging | IMPORTANT | A09 |

## Framework-specific

| ID | Anti-pattern | Fix | Sev | OWASP |
|----|--------------|-----|-----|-------|
| RX1 | Next.js Server Action without auth check | Check `auth()`/session and role inside the action | CRITICAL | A01 |
| RX2 | Client component reading `process.env` without `NEXT_PUBLIC_` | Only expose intended public vars | IMPORTANT | A02 |
| RX3 | RSC serialization leaking DB fields | Pick only needed fields before passing to client components | IMPORTANT | A01 |
| RX4 | `middleware.ts` matcher not covering `/api/` | Cover API routes | IMPORTANT | A01 |
| NG1 | `bypassSecurityTrust*` with user input | Sanitize with DOMPurify first | CRITICAL | A05 |
| NG2 | Template expression injection | No `JitCompilerFactory` with user-controlled templates | IMPORTANT | A05 |
| NG3 | Auth not attached via interceptor | Central `HttpInterceptorFn` | IMPORTANT | A07 |
| EX1 | Missing helmet | `app.use(helmet())`, `app.disable('x-powered-by')` | IMPORTANT | A02 |
| EX2 | `express.json()` without limit | Set `limit` | IMPORTANT | A05 |
| EX3 | Cookies without flags | `httpOnly`, `secure`, `sameSite`, `maxAge`, `path` | IMPORTANT | A07 |
| EX4 | Error handler exposing stack traces | Details only in development | IMPORTANT | A10 |
| GO1 | `math/rand` for security values | `crypto/rand` | CRITICAL | A04 |
| GO2 | TLS `InsecureSkipVerify: true` | Use the system CA pool | CRITICAL | A04 |
| GO3 | `fmt.Sprintf` in SQL | Parameterized queries (`db.Where("id = ?", id)`) | CRITICAL | A05 |

## JWT validation

1. Verify the signature with an enforced algorithm (`RS256`/`ES256`); reject `alg: none`.
2. Check `exp`, `iat`, `aud` and `iss`.
3. Store in an httpOnly cookie, never `localStorage`.
4. Use ~15-minute access tokens with rotated one-time-use refresh tokens; rotate signing keys periodically.

## Cookies

Session cookies: `HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=<explicit>`. Use `SameSite=Lax` only when a cross-site top-level navigation must carry the cookie (e.g. OAuth return).

## Baseline checklist

- Passwords: Argon2id or bcrypt (cost >= 12); MFA for privileged accounts.
- Server-side auth, ownership checks and input validation on every endpoint.
- Parameterized queries; sanitized HTML output; no stack traces in production responses.
- No hardcoded secrets; `.env` ignored; environment variables validated at startup.
- CSP (nonce-based), HSTS, `nosniff`, `X-Frame-Options: DENY`, strict Referrer-Policy, Permissions-Policy, CORS limited to known origins.
- Dependency audit passing in CI, lockfile committed, no wildcard versions.
- Security events logged with correlation IDs; no sensitive data in logs; alerting on anomalies.
