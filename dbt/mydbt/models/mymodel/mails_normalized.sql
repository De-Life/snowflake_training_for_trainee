{{ config(
    materialized='table',
    schema='NORMALIZED'
) }}

WITH labels AS (
    SELECT ARRAY_AGG(LABEL) AS label_array
    FROM {{ this.database }}.NORMALIZED.CLASSIFY_TEXT_LABELS
),

ai_processed AS (
    SELECT
        raw.MESSAGE_ID,
        raw.SUBJECT,
        raw.FROM_EMAIL,
        raw.RECEIVED_AT,
        SNOWFLAKE.CORTEX.SUMMARIZE(raw.BODY_TEXT) AS summary,
        SNOWFLAKE.CORTEX.CLASSIFY_TEXT(raw.BODY_TEXT, labels.label_array) AS classify_result,
        SNOWFLAKE.CORTEX.SENTIMENT(raw.BODY_TEXT) AS sentiment_score,
        SNOWFLAKE.CORTEX.COMPLETE(
            'mistral-large',
            CONCAT(
                'Extract 3-5 important keywords from the following email body. Return only a JSON array of strings. Body: ',
                raw.BODY_TEXT
            )
        ) AS keywords
    FROM {{ source('raw', 'MAILS_RAW') }} AS raw
    CROSS JOIN labels
)

SELECT
    MESSAGE_ID,
    SUBJECT,
    FROM_EMAIL,
    RECEIVED_AT,
    TRUE AS AI_PROCESSED,
    summary AS AI_SUMMARY,
    classify_result:label::VARCHAR AS AI_CATEGORY,
    CASE
        WHEN sentiment_score > 0.3 THEN 'positive'
        WHEN sentiment_score < -0.3 THEN 'negative'
        ELSE 'neutral'
    END AS AI_SENTIMENT,
    keywords AS AI_KEYWORDS,
    OBJECT_CONSTRUCT(
        'summary', summary,
        'classify', classify_result,
        'sentiment_score', sentiment_score,
        'keywords', keywords
    ) AS AI_RAW_RESULT,
    CURRENT_TIMESTAMP() AS NORMALIZED_AT
FROM ai_processed