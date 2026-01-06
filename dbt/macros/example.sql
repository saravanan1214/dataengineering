
{% macro hello(name) %}
select '{{ name }}' as greeting
{% endmacro %}
