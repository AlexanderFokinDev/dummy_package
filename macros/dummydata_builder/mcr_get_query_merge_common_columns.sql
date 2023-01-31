
{%- macro mcr_get_query_merge_common_columns(source_scheme1, source_table_name1, source_scheme2, source_table_name2) -%}

{#  Get equal columns in 2 tables #}

WITH

source_columns_table1 as (
	SELECT 
		name, 
		type, 
		1 as count 
	FROM system.columns
	WHERE  
		database = '{{ source_scheme1 }}' 
		and table = '{{ source_table_name1 }}'
),
	
source_columns_table2 as (
	SELECT 
		name, 
		type, 
		1 as count 
	FROM system.columns
	WHERE  
		database = '{{ source_scheme2 }}' 
		and table = '{{ source_table_name2 }}'
),
	
union_source_tables as (
	SELECT *
	FROM source_columns_table1
	
	UNION ALL
	
	SELECT *
	FROM source_columns_table2
),

common_columns_with_types as (
	SELECT 
		name, 
		any(type) as type
	FROM union_source_tables
	GROUP BY name
    HAVING sum(count) = 2
)

SELECT *
FROM common_columns_with_types

{%- endmacro -%}