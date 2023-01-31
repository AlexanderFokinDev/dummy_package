# dbt Dummy package

The macros in the repository will allow you to transform the real data from the original table into a table with dummy data.

### Example 1:

You should create a sql model with any name:

*my_dummy_table.sql*

```jinja

{%- set obfuscated_fields = ['id', 'name', 'ad_id', 'ad_name',
 'adset_id', 'adset_name','campaign_id', 'campaign_name', 'image'] -%}

{{ mcr_obfuscate_table('dataset_1', 'productive_facebook_data',, 1000, 1, obfuscated_fields) }}
```

>Where **1000** - limit rows in month,
**1** - limit years,
**obfuscated_fields** - list of string fields that'll be changed (*if you don't put this parameter, than all string fields will be changed as dummy*)


### Example 2:

Also you can unite two source tables into one with dummy data.

You should create a sql model with any name:

*my_united_dummy_table.sql*

```jinja
{{ config(materialized='table', alias='my_united_super_table') }}

{% set merge_request = mcr_get_query_merge_common_columns('dataset_1', 'productive_facebook_data', 'dataset_1', 'productive_tiktok_data') -%}

{%- set obfuscated_fields = ['id', 'name', 'ad_id', 'ad_name',
 'adset_id', 'adset_name','campaign_id', 'campaign_name', 'image'] -%}

{{ mcr_obfuscate_table('dataset_1', 'productive_facebook_data', merge_request, 1000, 1, obfuscated_fields) }}

union all

{{ mcr_obfuscate_table('dataset_1', 'productive_tiktok_data', merge_request, 1000, 1, obfuscated_fields) }}
```

>Where **config(materialized='table', alias='my_united_super_table')** - you'll get table not view with new name (alias)


## Macro mcr_obfuscate_table 

The `mcr_obfuscate_table` macro takes in a source scheme, source table name, merge request (optional), limit on number of rows to be obfuscated by month, limit on number of years to be obfuscated, and a list of fields to be obfuscated. The macro then replaces the specified fields in the source table with dummy values, effectively obfuscating the data. 

### Inputs
- `source_scheme`: name of the source scheme.
- `source_table_name`: name of the source table.
- `merge_request` (optional): the merge request number for tracking purposes.
- `limit_rows_by_month`: the maximum number of rows to be obfuscated per month.
- `limit_years`: the number of years to be obfuscated.
- `obfuscated_fields`: list of fields to be obfuscated.

### Outputs
The output of this macro is a table with obfuscated data.

## Macro mcr_get_query_merge_common_columns 

The `mcr_get_query_merge_common_columns` macro takes in two source schemes and table names and returns a list of common columns between the two tables. 

### Inputs
- `source_scheme1`: name of the first source scheme.
- `source_table_name1`: name of the first source table.
- `source_scheme2`: name of the second source scheme.
- `source_table_name2`: name of the second source table.

### Outputs
The output of this macro is a list of common columns between the two input tables.

## Usage

To use these macros in your dbt project, include this repository as a package in your `packages.yml` file. 

```yml
packages:
  - git: https://github.com/AlexanderFokinDev/dummy_package.git
    revision: release_version
```

Launch a command **dbt deps**

Then, reference the macros in your dbt models as needed.

```jinja
{{ dummy_package.mcr_obfuscate_table('dataset_1', 'productive_tiktok_data') }}
```