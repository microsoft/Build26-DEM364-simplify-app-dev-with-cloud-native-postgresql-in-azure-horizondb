SET search_path = public, pgfts;

CREATE EXTENSION IF NOT EXISTS pg_fts;

CREATE INDEX IF NOT EXISTS idx_product_sample_fts ON public.embedding_pipeline_output
USING fts (chunk_text text_fts_ops);

CREATE INDEX IF NOT EXISTS idx_product_sample_diskann ON public.embedding_pipeline_output
USING diskann (embedding vector_cosine_ops);

-- =============================================================================
-- Skipped Step - Describes the room photo in text to identify style, colors
-- =============================================================================

-- Search for furniture and decor matching the room design query
--
-- NOTE on the join back to product_sample:
-- The pipeline's `doc_id` is an internal per-run document ordinal (1..N), NOT
-- the source `product_sample.id`. Joining on `product.id = product_output.doc_id`
-- would only match the handful of products whose id happens to fall in that 1..N
-- range, silently dropping the rest. Because every product embeds as a single
-- chunk, `chunk_text` equals the original `content`, so we join on the text to
-- map each match back to its real product.
SELECT product.id, product.title, product.price, product.category, search.score
FROM public.search(
    query          => 'mid-century modern furniture for Brooklyn loft living room with wood tones and dark vibe',
    source_table   => 'embedding_pipeline_output',
    content_column => 'chunk_text',
    search_type    => 'hybrid',
    top_k          => 100) search
JOIN embedding_pipeline_output product_output ON product_output.id = search.id
JOIN product_sample product ON product.content = product_output.chunk_text
ORDER BY search.score DESC;
