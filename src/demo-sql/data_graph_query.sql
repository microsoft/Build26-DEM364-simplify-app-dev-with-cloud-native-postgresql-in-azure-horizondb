-- =============================================================================
-- Skipped Step - Create knowledge graph using AI pipeline and graph queries.
-- =============================================================================

-- Knowledge graph retrieval queries ──────────────────────────────────────────────────
SET search_path = ag_catalog, "$user", public, pgfts;

-- "I picked this coffee table. What rugs, lamps, and chairs match its style?"
SELECT * FROM ag_catalog.cypher('style_graph', $$
    MATCH (seed:Product {id: 10414})-[e1:HAS_STYLE]->(s:Style)<-[e2:HAS_STYLE]-(recommendation:Product)
    MATCH (seed)-[e3:IN_CATEGORY]->(seedCat:Category)
    MATCH (recommendation)-[e4:IN_CATEGORY]->(recCat:Category)
    MATCH (sibling:Product)-[e5:IN_CATEGORY]->(recCat)
    WHERE seedCat.name <> recCat.name
    RETURN seed, e1, s, e2, recommendation, e3, seedCat, e4, recCat, sibling, e5
    LIMIT 20
$$) AS (seed agtype, e1 agtype, style agtype, e2 agtype, recommendation agtype, e3 agtype, seedCat agtype, e4 agtype, recCat agtype, sibling agtype, e5 agtype);

-- 2-HOP: "Products in styles SIMILAR to mine, across different categories"
-- The AI discovered style relationships → the graph traverses them
SELECT * FROM ag_catalog.cypher('style_graph', $$
    MATCH (seed:Product {id: 2315})-[e1:HAS_STYLE]->(s:Style)-[e2:SIMILAR_TO]->(related:Style)<-[e3:HAS_STYLE]-(rec:Product)
    MATCH (seed)-[e4:IN_CATEGORY]->(seedCat:Category)
    MATCH (rec)-[e5:IN_CATEGORY]->(recCat:Category)
    WHERE seedCat.name <> recCat.name
    RETURN seed, e1, s, e2, related, e3, rec, e4, seedCat, e5, recCat
    LIMIT 5
$$) AS (seed agtype, e1 agtype, style agtype, e2 agtype, related agtype, e3 agtype, rec agtype, e4 agtype, seedCat agtype, e5 agtype, recCat agtype);

