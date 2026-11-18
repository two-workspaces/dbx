# Deploy and Host DBX on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/database-client?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=database-client)

DBX is a lightweight open-source database client for more than 100 databases: PostgreSQL, MySQL, MariaDB, SQLite, Redis, MongoDB, ClickHouse, SQL Server, Oracle, Elasticsearch, DuckDB, CockroachDB and many more. It has a SQL editor with autocomplete, an editable data grid, schema and ER diagrams, import and export, data transfer between databases, scheduled backups, an AI SQL assistant and a built-in MCP server. This template runs the official DBX Web image (0.6.71) on Railway as one small service, locked with a generated password and with its data kept on a volume.

This is a community template, not made or supported by the DBX authors.

## About Hosting DBX

Open your Railway domain and log in with the password in the service's `DBX_PASSWORD` variable (Railway generates it at deploy). Then add a connection.

**Connect to a Railway database:** deploy DBX in the same project as the database and use its private host, for example `postgres.railway.internal` on port `5432`, with the user, password and database name from the database service's variables. Private traffic never leaves Railway and needs no public TCP proxy. For a database in another project, or outside Railway, use its public host and port.

**The password:** `DBX_PASSWORD` is applied on every boot, so change it in the variable and redeploy. If you delete the variable, DBX asks the first visitor to set a password, so keep it set while the domain is public. After a wrong password the login asks for a captcha, and repeated failures lock it for a while.

**Your data:** saved connections (passwords encrypted with a key kept on the volume), query history, snippets, installed drivers and plugins, and scheduled backups all live on the volume at `/app/data`, so they survive redeploys.

**MCP for AI agents:** set `DBX_WEB_MCP_TOKEN` to a long random string and redeploy. DBX then serves Streamable HTTP MCP at `https://your-domain/mcp`; clients send `Authorization: Bearer` with that token. Agents can list connections, read schemas and run queries under the policy in Settings > MCP (read-only, or with writes). `DBX_WEB_MCP_ALLOWED_HOSTS` defaults to the Railway domain; add your custom domain there if you use one.

## Common Use Cases

- A browser database client for the Postgres, MySQL, Redis or MongoDB services in your Railway project
- One shared, password-protected place for a team's database connections
- Moving data between databases, exporting tables and running scheduled backups
- Letting Claude, Codex or another MCP client query your databases through DBX's MCP server

## Dependencies for DBX Hosting

- None. Bring the databases you want to connect to.

### Deployment Dependencies

- [DBX on GitHub](https://github.com/t8y2/dbx)
- [DBX documentation](https://dbxio.com)
- [Template source](https://github.com/two-workspaces/dbx)

### Implementation Details

- **Tested on Railway:** the healthcheck, the login lock (every API call answers 401 without a session), logging in with the generated password, connecting to a Railway Postgres 18 over the private network, creating a table and querying it, the saved connection surviving a redeploy, and the MCP endpoint (401 without the token, then `tools/list` and a query with it). Not tested: the web UI in a real browser (its assets load), other database types, the AI assistant and the JDBC-based drivers.
- **Memory:** about 80 MB idle and 115 MB after queries and MCP calls in our test, so it fits a 0.5 GB plan. Drivers that run on Java (H2, Snowflake, Trino, DB2 and other agent-based ones) start a JVM and need more.
- **Safety guards:** an empty `DBX_PASSWORD` would become a valid empty password in DBX, so the start script ignores it instead. An empty or unusable `DBX_WEB_MCP_TOKEN` would stop DBX from starting, so the script leaves MCP off with a log line.
- **Port:** DBX listens on `PORT` (4224). The login cookie is marked Secure (`DBX_WEB_COOKIE_SECURE=1`) because Railway serves the domain over HTTPS.
- **Image:** upstream's `t8y2/dbx:0.6.71`, pinned to the stable release, plus a small start script.

## Why Deploy DBX on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying DBX on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
