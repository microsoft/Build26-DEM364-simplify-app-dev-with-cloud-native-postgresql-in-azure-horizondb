-- Clean up pipeline (removes triggers, checkpoints, and run history)
SELECT ai.drop('embedding_pipeline');

DELETE FROM ai.pipelines WHERE name = 'embedding_pipeline';
DROP TABLE IF EXISTS embedding_pipeline_output CASCADE;

-- Drop the output table
DROP TABLE IF EXISTS embedding_pipeline_output CASCADE;

DELETE FROM product_sample
WHERE title = 'New Chair for Living Room';

-- DELETE FROM style_tagger_output
--  WHERE title = 'New Chair for Living Room';

SELECT ai.drop('style_tagger');