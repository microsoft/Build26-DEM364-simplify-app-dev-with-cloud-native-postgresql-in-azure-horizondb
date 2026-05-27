
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- DATA RETRIEVAL: Real Queries for Roommate UI Demo
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- =============================================================================
-- SETUP: pg_fts Extension & BM25 Index
-- =============================================================================

SET search_path = public, pgfts;

CREATE EXTENSION IF NOT EXISTS pg_fts;

CREATE INDEX IF NOT EXISTS idx_product_sample_fts ON public.product_rag_pipeline_build_2026_output
USING fts (chunk_text text_fts_ops);

CREATE INDEX IF NOT EXISTS idx_product_sample_diskann ON public.product_rag_pipeline_build_2026_output
USING diskann (embedding vector_cosine_ops);

-- Add id PK (auto-generated, not tied to doc_id since chunks share doc_ids)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'product_rag_pipeline_build_2026_output' AND column_name = 'id'
    ) THEN
        EXECUTE 'ALTER TABLE product_rag_pipeline_build_2026_output ADD COLUMN id SERIAL PRIMARY KEY';
    END IF;
END
$$;

-- =============================================================================
-- Room Analysis: azure_ai.generate() with image URL
-- Describes the room photo to identify style, furniture, colors, and gaps
-- =============================================================================
-- 1. 
-- SELECT azure_ai.generate(
--   'Recommended the style for this. https://i.ibb.co/p61fm20N/Designer.png
--   ['Mid-Century Modern', 'Industrial', 'Scandinavian','Bohemian', 'Farmhouse', 'Minimalist']'
-- );

-- 2. 
-- SELECT azure_ai.generate(
--   'Analyze this living room photo. https://i.ibb.co/p61fm20N/Designer.png
--   give a semantic description of the room'
-- );

-- =============================================================================
-- Product Search: ai.search_orig() with semantic ranking and category filters
-- Searches for furniture and decor matching the room design query
-- =============================================================================

-- Search for furniture and decor matching the room design query
SELECT product.id, product.title, product.price, product.category, search.score
FROM ai.search(
    query          => 'mid-century modern furniture for Brooklyn loft living room with wood tones and dark vibe',
    source_table   => 'product_rag_pipeline_build_2026_output',
    content_column => 'chunk_text',
    search_type    => 'hybrid',
    rerank         => true,
    top_k          => 10) search
JOIN product_rag_pipeline_build_2026_output product_output ON product_output.id = search.id
JOIN product_sample product ON product.id = product_output.doc_id
ORDER BY search.score DESC;

SELECT *
FROM ai.search(
    'mid-century modern furniture for Brooklyn loft living room with wood tones and dark vibe',
    'product_rag_pipeline_build_2026_output',
    'chunk_text',
    search_type => 'hybrid',
    rerank      => true,
    top_k       => 10) search;

-- 2. EXPLAIN ANALYZE — reveals the BM25 / diskann / RRF join structure
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT product.id, product.title, product.price, product.category, search.score
FROM ai.search(
    'mid-century modern furniture for Brooklyn loft living room with wood tones and dark vibe',
    'product_rag_pipeline_build_2026_output',
    'chunk_text',
    search_type => 'hybrid',
    top_k       => 50) search
JOIN product_rag_pipeline_build_2026_output product_output ON product_output.id = search.id
JOIN product_sample product ON product.id = product_output.doc_id
WHERE product.category = 'Chairs'
ORDER BY search.score DESC;
