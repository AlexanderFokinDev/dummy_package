
{%- macro mcr_obfuscate_field(value, type, last_date, data_value_scale_correction=1, obfuscated_fields=[]) -%}

{%- if type == 'String' and (obfuscated_fields==[] or value in obfuscated_fields) -%}
    'dummy_string'
{%- elif type == 'String' -%}
    {{ value }}
{%- elif type == 'Float64' -%}
    round( {{ value }} * {{ data_value_scale_correction }} )
{%- elif type == 'Date' -%}  
    DATE_ADD(DAY, if(toDate({{ last_date }}) < toStartOfDay( today() ),
      DATE_DIFF(DAY, toDate({{ last_date }}), toStartOfDay( today() )), 0), toDate({{ value }}))
{%- elif type == 'DateTime' -%}
    now()
{%- else -%}
    ''
{%- endif -%}

{%- endmacro -%}