<a name="start-building"></a>
<br>
<p align="center">
<img src="img/banner-build-26.png" alt="Microsoft Build 2026" width="1200"/>
</p>

# [Microsoft Build 2026](https://build.microsoft.com)

## 🔥 DEM364: Zava Designer Agent — One Database, Every Layer of the AI Stack

### Session Description

Build the **Zava Designer Agent** — an AI-powered room designer that analyzes a photo of your living room and recommends furniture from a 100K-product catalog — using nothing but **Azure HorizonDB** (Azure's cloud-native PostgreSQL service).

No Pinecone. No Neo4j. No separate reranker service. Vector search, full-text search, graph traversal, multimodal embeddings, reranking, and AI pipelines all run inside one Postgres database. This demo walks through a 6-tool agent pipeline — from `azure_ai.generate()` reading the room photo, to `ai.search()` doing BM25 + DiskANN + semantic reranking in one call, to Apache AGE Cypher queries traversing a style graph, to `azure_ai.rank()` curating the final picks.

### 🛠️ What It Does

Upload a room photo. The agent analyzes it, searches 100K Amazon Home & Kitchen products, traverses a style graph, reranks results, and picks six furniture pieces that fit — all from a single HorizonDB instance.

The 6-tool agent pipeline:

| Step | Tool | HorizonDB Feature | Purpose |
|------|------|--------------------|---------|
| 1 | `analyzeRoomPhoto` | `azure_ai.generate()` | LLM reads the room photo — identifies style, colors, gaps |
| 2 | `getSemanticContext` | `pg_catalog` + `semantic_dictionary` | Schema introspection and search term expansion |
| 3 | `hybridSearchProducts` | `ai.search()` × 6 categories | BM25 + DiskANN + semantic reranking in one call |
| 4 | `findRelatedProducts` | Apache AGE Cypher / `bought_together` | Graph traversal for style-connected products |
| 5 | `filterProducts` | SQL `WHERE` | Budget ceiling + minimum rating enforcement |
| 6 | `curateRoomPicks` | `azure_ai.rank()` | Semantic reranking, best-per-category selection |

### 🧱 Tech Stack

- **Database:** Azure HorizonDB (PostgreSQL) with extensions: `azure_ai`, `pg_fts`, `age`, `vector`
- **Frontend:** React 18 + Vite 6
- **Backend:** Express 4 + node-postgres
- **Data:** ~100K Amazon Home & Kitchen products in `product_metadata_demo`

### 📁 Repository Structure

```
.
├── README.md                                       # This file
├── docs/
│   └── ui-component-playbook.md                    # How the UI was built (component playbook)
└── src/
    ├── demo-sql/                                   # SQL scripts for the demo features
    │   ├── data_ingest_with_ai_pipelines.sql       # AI Pipeline: chunk + embed 100K products
    │   ├── data_retrieval_with_ai_search.sql       # Hybrid search with reranking
    │   ├── data_graph_query.sql                    # Apache AGE graph queries
    │   └── setup/                                  # One-time setup scripts
    │       ├── setup.sql                           # Extensions and base config
    │       ├── ai-search.sql                       # Search index setup
    │       ├── graph_creation.sql                  # AGE graph schema
    │       ├── cleanup.sql                         # Teardown script
    │       └── data/                               # Sample data + table DDL
    │           ├── product-sample-table.sql        # Product table DDL
    │           └── product_sample_may13.csv        # Sample product data
    └── zava-designer-agent-ui-demo/                # Full-stack web app
        ├── server.js                               # Express backend — 6-tool pipeline
        ├── package.json                            # Dependencies
        ├── vite.config.js                          # Dev server config
        ├── public/                                 # Room photos + logos
        └── src/                                    # React frontend
            ├── App.jsx                             # Main layout + state machine
            ├── index.css                           # All styles (~2000 lines)
            ├── main.jsx                            # React entry point
            ├── components/                         # UI components
            │   ├── AgentTrace.jsx                  # Tool call details overlay
            │   ├── ChatBubble.jsx                  # Floating chat panel
            │   ├── DesignDrawer.jsx                # Settings drawer
            │   ├── DesignPanel.jsx                 # Design controls panel
            │   ├── ProductCard.jsx                 # Individual product display
            │   ├── QueryTrace.jsx                  # Pipeline steps visualization
            │   ├── RoomView.jsx                    # Room photo + product dots
            │   └── SuggestionsPanel.jsx            # Right sidebar with picks
            └── data/
                └── mockData.js                     # Fallback data for offline dev
```

### ✅ Prerequisites

- **Azure HorizonDB server** with the following extensions enabled: `azure_ai`, `pg_fts`, `age`, `vector`
- **Model Management enabled** on the HorizonDB server (Azure Portal → AI Settings → Enable Model Management) — provides `default-embedding` and `default-chat` models
- **Node.js** 18+ and npm
- **Product data** loaded into `product_metadata_demo` table (~100K rows)

## ⚡ Quick Start

### 1. Set up the database

Run the setup scripts against your HorizonDB instance in order:

```bash
# Connect to your HorizonDB server with psql, then run:
\i src/demo-sql/setup/setup.sql
\i src/demo-sql/setup/data/product-sample-table.sql
\i src/demo-sql/setup/ai-search.sql
\i src/demo-sql/setup/graph_creation.sql
```

> **Note:** The `private/` folder contains internal function definitions (`ai-pipelines-setup.sql`, `ai-search-internal.sql`) that must be run on the server before the demo scripts. These are gitignored and not published — contact the demo owner for access.

### 2. Load sample data

```bash
# Load product data from CSV
\copy product_sample FROM 'src/demo-sql/setup/data/product_sample_may13.csv' WITH (FORMAT csv, HEADER true);
```

### 3. Run the demo scripts

```bash
\i src/demo-sql/data_ingest_with_ai_pipelines.sql
\i src/demo-sql/data_retrieval_with_ai_search.sql
\i src/demo-sql/data_graph_query.sql
```

### 4. Start the web app

```bash
cd src/zava-designer-agent-ui-demo

# Create .env with your HorizonDB credentials
cat > .env <<EOF
PGHOST=<your-horizondb-server>.horizondb.azure.com
PGPORT=5432
PGDATABASE=postgres
PGUSER=<your-username>
PGPASSWORD=<your-password>
EOF

npm install
npm run dev:full
```

The frontend opens at `http://localhost:5180` and proxies API calls to the Express backend on `:3001`.

### 5. Use the app

1. Open `http://localhost:5180`
2. Click **"Design My Room"**
3. Watch the 6-tool pipeline execute — room analysis → hybrid search → graph traversal → reranking
4. Explore the product dots on the furnished room photo
5. Click **"⚡ How did this work?"** for the pipeline visualization or **"⚙️ Agent Details"** for raw SQL + JSON traces

## ✨ Key HorizonDB Features Demonstrated

**⚡ AI Pipelines (`ai.create_pipeline`, `ai.run`)**

 - Chunk and embed 100K products with two lines of SQL. The `on_change` trigger auto-processes new inserts.

**⚡ Hybrid Search (`ai.search`)**

 - BM25 full-text + DiskANN vector + RRF fusion + semantic reranking — all in a single function call, filtered by category.

**⚡ Graph Traversal (Apache AGE)**

 - AI-extracted style tags (`ai.extract`) build a property graph: `(:Product)-[:HAS_STYLE]->(:Style)-[:SIMILAR_TO]->(:Style)`. Cypher queries discover cross-category, cross-style recommendations.

**⚡ AI Functions (`azure_ai.generate`, `azure_ai.rank`)**

 - Call LLMs and rerankers directly from SQL — no external service orchestration needed.

### 🧠 Learning Outcomes

By the end of this session, you will be able to:

- Stand up an end-to-end RAG pipeline inside Azure HorizonDB using `ai.create_pipeline` and `on_change` triggers to chunk and embed data automatically
- Run **hybrid search** (BM25 + DiskANN + RRF fusion + semantic reranking) across a multi-category product catalog in a single `ai.search()` call
- Use **Apache AGE Cypher** queries to traverse an AI-extracted property graph for style-based, cross-category product discovery
- Orchestrate an agent that calls LLMs (`azure_ai.generate`) and rerankers (`azure_ai.rank`) directly from SQL — without external service plumbing
- Architect an AI application where one database replaces the vector DB, graph DB, search service, and reranker tier

### 💬 Keep Learning with Copilot

Try these prompts with GitHub Copilot to explore the topics from this session. Open Copilot Chat in Visual Studio Code (`Ctrl+Alt+I` on Windows/Linux, `Cmd+Shift+I` on Mac), paste a prompt, and see what you learn. Try connecting the [Microsoft Learn MCP Server](#-microsoft-learn-mcp-server) for the latest official documentation.

Use these as a starting point — or write your own!

- *"Explain how `ai.create_pipeline` in Azure HorizonDB chunks and embeds data, and how the `on_change` trigger keeps the index fresh."*
- *"Show me how `ai.search()` combines BM25, DiskANN vector search, RRF fusion, and semantic reranking in one call. What knobs can I tune?"*
- *"Walk me through writing an Apache AGE Cypher query that traverses `(:Product)-[:HAS_STYLE]->(:Style)-[:SIMILAR_TO]->(:Style)` to find cross-category recommendations."*
- *"How do I call `azure_ai.generate()` and `azure_ai.rank()` from SQL? What models are available with HorizonDB Model Management?"*
- *"Design a 6-tool agent that turns a room photo into furniture recommendations using only PostgreSQL. What does each tool do?"*

### 📚 Resources and Next Steps

| Resource | Description |
|:---------|:------------|
| [Azure Database for PostgreSQL documentation](https://learn.microsoft.com/azure/postgresql/) | Official docs for Azure's managed PostgreSQL service (HorizonDB family) |
| [Apache AGE documentation](https://age.apache.org/age-manual/master/index.html) | Graph extension for PostgreSQL — Cypher inside Postgres |
| [pgvector documentation](https://github.com/pgvector/pgvector) | Vector similarity search for PostgreSQL |
| [UI Component Playbook](./docs/ui-component-playbook.md) | How the Zava Designer Agent UI was built — component-by-component |
| [https://aka.ms/build26-next-steps](https://aka.ms/build26-next-steps) | Explore lab and session repos to further your learning from Microsoft Build |


### 🌟 Microsoft Learn MCP Server

The Microsoft Learn MCP Server gives your AI agent direct access to Microsoft's official documentation — grounded, up-to-date answers about the products and services covered in this session.

**VS Code** — One click installation: 

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Microsoft_Learn_MCP-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://vscode.dev/redirect/mcp/install?name=microsoft-learn&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)


**GitHub Copilot CLI** — Run this to install the Learn MCP Server as a plugin:
```
/plugin install microsoftdocs/mcp
```

For more info, other clients, and to post questions, visit the [Learn MCP Server repo](https://aka.ms/learnmcp).

## Content Owners

<!-- TODO: Add yourself as a content owner
1. Change the src in the image tag to {your github url}.png
2. Change INSERT NAME HERE to your name
3. Change the github url in the final href to your url. -->

<table>
<tr>
    <td align="center"><a href="http://github.com/yourGitHubHandle">
        <img src="https://github.com/yourGitHubHandle.png" width="100px;" alt="INSERT NAME HERE"/><br />
        <sub><b>INSERT NAME HERE</b></sub></a><br />
            <a href="https://github.com/yourGitHubHandle" title="talk">📢</a>
    </td>
</tr></table>

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
