SELECT * FROM product_sample LIMIT 5;
SELECT * FROM model_registry.model_list_all();

-- ---------------------------------------------------------------------------
-- Embedding Pipeline in Seconds
-- ---------------------------------------------------------------------------

SELECT ai.create_pipeline(
    name    => 'product_rag_pipeline_build_2026',
    source  => ai.table_source('product_sample'),
    steps   => ARRAY[
        ai.chunk(input => 'content',
                 chunk_size => 1024, 
                 overlap => 128), -- generates chunk_text, chunk_index, etc.
        ai.embed(model => 'default-embedding', 
                 input_column => 'chunk_text',
                 dimensions => 1536,
                 batch_size => 20)
    ],
    trigger => 'on_change'
);
SELECT ai.run('product_rag_pipeline_build_2026');

-- ---------------------------------------------------------------------------
-- Monitor Pipeline 
-- ---------------------------------------------------------------------------

SELECT * FROM ai.status('product_rag_pipeline_build_2026');

-- ---------------------------------------------------------------------------
-- Look at output table
-- ---------------------------------------------------------------------------

SELECT count(*) FROM product_rag_pipeline_build_2026_output;
SELECT * FROM product_rag_pipeline_build_2026_output;

-- Semantic search against the catalog.
SELECT doc_id, chunk_text, chunk_index
     FROM product_rag_pipeline_build_2026_output
     ORDER BY embedding <=> azure_openai.create_embeddings(
                                'default-embedding',
                                'Best chair that is comfortable for a living room')::vector
     LIMIT 5;
    
-- ---------------------------------------------------------------------------
-- Auto-Embedding on New Rows
-- ---------------------------------------------------------------------------

INSERT INTO product_sample (title, content)
VALUES (
    'New Chair for Living Room',
    'A comfortable and stylish chair perfect for any living room setting. Features ergonomic design, high-quality materials, and a modern aesthetic that complements various interior styles.'
);

SELECT count(*) FROM product_rag_pipeline_build_2026_output;

SELECT *
     FROM product_rag_pipeline_build_2026_output
     ORDER BY embedding <=> azure_openai.create_embeddings(
                                'default-embedding',
                                'Best chair that is comfortable for a living room')::vector
     LIMIT 5;
