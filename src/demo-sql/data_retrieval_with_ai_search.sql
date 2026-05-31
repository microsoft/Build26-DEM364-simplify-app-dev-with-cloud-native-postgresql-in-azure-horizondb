SET search_path = public, pgfts;

CREATE EXTENSION IF NOT EXISTS pg_fts;

CREATE INDEX IF NOT EXISTS idx_product_sample_fts ON public.product_rag_pipeline_build_2026_output
USING fts (chunk_text text_fts_ops);

CREATE INDEX IF NOT EXISTS idx_product_sample_diskann ON public.product_rag_pipeline_build_2026_output
USING diskann (embedding vector_cosine_ops);

-- =============================================================================
-- Prior Step - Room Analysis: Describes the room photo to identify style, furniture, colors, and gaps
-- =============================================================================

-- Search for furniture and decor matching the room design query
SELECT product.id, product.title, product.price, product.category, search.score
FROM ai.search(
    query          => 'mid-century modern furniture for Brooklyn loft living room with wood tones and dark vibe',
    source_table   => 'product_rag_pipeline_build_2026_output',
    content_column => 'chunk_text',
    search_type    => 'hybrid',
    top_k          => 10) search
JOIN product_rag_pipeline_build_2026_output product_output ON product_output.id = search.id
JOIN product_sample product ON product.id = product_output.doc_id
ORDER BY search.score DESC;
