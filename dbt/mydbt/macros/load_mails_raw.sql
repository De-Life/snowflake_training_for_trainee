{% macro load_mails_raw() %}
    {% set copy_sql %}
        COPY INTO {{ source('raw', 'MAILS_RAW') }}
        FROM @{{ source('raw', 'ST_S3_MAIL') }}
        MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
        FORCE = TRUE
    {% endset %}

    {% do run_query(copy_sql) %}
    {{ log("load_mails_raw: COPY completed.", info=True) }}
{% endmacro %}