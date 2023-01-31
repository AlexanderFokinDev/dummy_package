{% macro mcr_obfuscate_table(source_scheme, source_table_name, merge_request='', limit_rows_by_month=20000, limit_years=2, obfuscated_fields=[]) -%}

WITH

-- INPUT ------------------------------------------------

    {#  Query gets not dummy date from a source -#}
    source_not_dummy_data AS (
        SELECT 
            * 
        FROM 
            {{ source(source_scheme, source_table_name) }}
        WHERE 
            YEAR(date) >= (YEAR(date) - {{ limit_years }})
        LIMIT {{ limit_rows_by_month }} BY toStartOfMonth(date)
    ),

    {# For generating random numbers in a range -#}
    4294967295 as max_uint_32,

    {#  Get max date in the source table -#}
    {%- set last_date = get_last_date(source_scheme, source_table_name) -%}

    {% set fields_result = get_all_columns_from_source_tables(source_scheme, source_table_name, merge_request) %}

-- SIMPLE OBFUSCATION ------------------------------------------
-- 1.3 - is a scale correction value for obfusctate numbers

    obfuscated_data_{{source_scheme}} AS (

        SELECT
        {%- for field in fields_result %}
            {{ mcr_obfuscate_field(field['name'], field['type'], last_date, 1.3, obfuscated_fields) }} AS {{ field['name'] }}
            {%- if not loop.last -%},
            {%- endif -%}
        {%- endfor %} 
        FROM source_not_dummy_data 
    )

-- OBFUSCATION WITH DUMMY DICTIONARY------------------------------


-- FINAL RESULT --------------------------------------------------

    SELECT *
    FROM obfuscated_data_{{source_scheme}}

{%- endmacro -%}

-- MACROS get_last_date() ------------------------------------------------

{#-  Macro gets the last date in a source. It needs to update date in all rows -#}
    {% macro get_last_date(source_scheme, source_table_name) %}

    {%- set query_max_date -%}
        select max(date) as max_date
        from {{ source(source_scheme, source_table_name) }}
    {%- endset -%}

    {%- set md_result = run_query(query_max_date) -%}
    {%- if md_result|length -%}
        {%- set last_date = "'" ~ md_result.rows[0]['max_date'] ~ "'" -%}
    {%- else -%}
        {%- set last_date = 'today()' -%}
    {%- endif -%}

    {{ return(last_date) }}

{% endmacro %}

-- MACROS get_all_columns_from_source_tables() ------------------------------------------------

{% macro get_all_columns_from_source_tables(source_scheme, source_table_name, merge_request) %}
    {#  Universal way to get all columns with types #}
    {%- set query_get_fields -%}
        {%- if merge_request == '' -%}
            DESCRIBE TABLE {{ source(source_scheme, source_table_name) }}
        {%- else -%}
            {{ merge_request }}
        {%- endif -%}
    {%- endset -%}
    {%- set fields_result = run_query(query_get_fields) %}

    {{ return(fields_result) }}

{% endmacro %}