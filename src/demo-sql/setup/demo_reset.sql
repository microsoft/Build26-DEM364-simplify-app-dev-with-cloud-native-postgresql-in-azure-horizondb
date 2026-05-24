SELECT ai.drop('product_rag_pipeline_build_2026');
DROP TABLE IF EXISTS product_rag_pipeline_build_2026_output;
DELETE FROM product_sample
WHERE title = 'New Chair for Living Room';