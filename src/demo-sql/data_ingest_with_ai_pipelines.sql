SELECT * FROM product_sample LIMIT 5;
SELECT * FROM model_registry.model_list_all();

-- ---------------------------------------------------------------------------
-- Embedding Pipeline in Seconds
-- ---------------------------------------------------------------------------

SELECT ai.create_pipeline(
    name    => 'embedding_pipeline',
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
SELECT ai.run('embedding_pipeline');

-- ---------------------------------------------------------------------------
-- Monitor Pipeline 
-- ---------------------------------------------------------------------------

SELECT * FROM ai.status('embedding_pipeline');

-- ---------------------------------------------------------------------------
-- Look at output table
-- ---------------------------------------------------------------------------

SELECT count(*) FROM embedding_pipeline_output;
SELECT * FROM embedding_pipeline_output;

-- Semantic search against the catalog.
SELECT doc_id, chunk_text, chunk_index
     FROM embedding_pipeline_output
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

SELECT count(*) FROM embedding_pipeline_output;

SELECT *
     FROM embedding_pipeline_output
     ORDER BY embedding <=> azure_openai.create_embeddings(
                                'default-embedding',
                                'Best chair that is comfortable for a living room')::vector
     LIMIT 5;
