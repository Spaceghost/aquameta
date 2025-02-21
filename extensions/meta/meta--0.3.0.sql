/*****************************************************************************
 * Meta Identifiers
 * A set of types that identify PostgreSQL DDL entities.
 *
 * Copyright (c) 2019 - Aquameta - http://aquameta.org/
 ****************************************************************************/

/*****************************************************************************
 * meta.schema_id
 ****************************************************************************/

set search_path=meta,public;

create type meta.schema_id as (
    name text
);


create function meta.schema_id(name text) returns meta.schema_id as $$
    select row(name)::meta.schema_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.schema_id,
    rightarg json
) returns boolean as $$
    select (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.schema_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.schema_id(value json) returns meta.schema_id as $$
    select row(value->>'name')::meta.schema_id
$$ immutable language sql;


create cast (json as meta.schema_id)
with function meta.schema_id(json)
as assignment;


/******************************************************************************
 * meta.type_id
 *****************************************************************************/
create type meta.type_id as (
    schema_id meta.schema_id,
    name text
);


create function meta.type_id(schema_name text, name text) returns meta.type_id as $$
    select row(row(schema_name), name)::meta.type_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.type_id,
    rightarg json
) returns boolean as $$
    select (leftarg).schema_id = rightarg->'schema_id' and
           (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.type_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.type_id(value json) returns meta.type_id as $$
    select row(row(value->'schema_id'->>'name'), value->>'name')::meta.type_id
$$ immutable language sql;


create cast (json as meta.type_id)
with function meta.type_id(json)
as assignment;

/******************************************************************************
 * meta.cast_id
 *****************************************************************************/
create type meta.cast_id as (
    source_type meta.type_id,
    target_type meta.type_id
);

create function meta.cast_id(source_type_schema_name text, source_type_name text, target_type_schema_name text, target_type_name text) returns meta.cast_id as $$
    select row(row(row(source_type_schema_name), source_type_name),
               row(row(target_type_schema_name), target_type_name))::meta.cast_id
$$ language sql immutable;



create function meta.eq(
    leftarg meta.cast_id,
    rightarg json
) returns boolean as $$
--TODO
    select (leftarg).source_type = rightarg->'source_type' and
           (leftarg).target_type = rightarg->'target_type';
$$ language sql;


create operator = (
    leftarg = meta.cast_id,
    rightarg = json,
    procedure = meta.eq
);


/*
create function meta.cast_id(value json) returns meta.cast_id as $$
--TODO
    select row(row(value->'schema_id'->>'name'), value->>'name')::meta.cast_id
$$ immutable language sql;


create cast (json as meta.cast_id)
with function meta.cast_id(json)
as assignment;
*/


/******************************************************************************
 * meta.operator_id
 *****************************************************************************/

create type meta.operator_id as (
    schema_id meta.schema_id,
    name text,
    left_arg_type_id meta.type_id,
    right_arg_type_id meta.type_id
);

create function meta.operator_id(
    schema_name text,
    name text,
    left_arg_type_schema_name text,
    left_arg_type_name text,
    right_arg_type_schema_name text,
    right_arg_type_name text
) returns meta.operator_id as $$
    select row(
        meta.schema_id(schema_name),
        name,
        meta.type_id(left_arg_type_schema_name, left_arg_type_name),
        meta.type_id(right_arg_type_schema_name, right_arg_type_name)
    )::meta.operator_id
$$ language sql immutable;

create function meta.eq(
    leftarg meta.operator_id,
    rightarg json
) returns boolean as $$
    select (leftarg).schema_id = rightarg->'schema_id' and
           (leftarg).name = rightarg->>'name' and
           (leftarg).left_arg_type_id = rightarg->'left_arg_type_id' and
           (leftarg).right_arg_type_id = rightarg->'right_arg_type_id';
$$ language sql;


create operator = (
    leftarg = meta.operator_id,
    rightarg = json,
    procedure = meta.eq
);

create function meta.operator_id(value json) returns meta.operator_id as $$
    select row(
        row(value->'schema_id'->>'name'),
        value->>'name',
        row(row(value->'left_arg_type_id'->'schema_id'->>'name'), value->>'name'),
        row(row(value->'right_arg_type_id'->'schema_id'->>'name'), value->>'name')
    )::meta.operator_id
$$ immutable language sql;


create cast (json as meta.operator_id)
with function meta.operator_id(json)
as assignment;


/******************************************************************************
 * meta.sequence_id
 *****************************************************************************/

create type meta.sequence_id as (
    schema_id meta.schema_id,
    name text
);


create function meta.sequence_id(
    schema_name text,
    name text
) returns meta.sequence_id as $$
    select row(row(schema_name), name)::meta.sequence_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.sequence_id,
    rightarg json
) returns boolean as $$
    select (leftarg).schema_id.name = rightarg->'schema_id'->>'name' and
           (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.sequence_id,
    rightarg = json,
    procedure = meta.eq
);



/******************************************************************************
 * meta.relation_id
 *****************************************************************************/

create type meta.relation_id as (
    schema_id meta.schema_id,
    name text
);


create function meta.relation_id(schema_name text, name text) returns meta.relation_id as $$
    select row(row(schema_name), name)::meta.relation_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.relation_id,
    rightarg json
) returns boolean as $$
    select (leftarg).schema_id = rightarg->'schema_id' and
           (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.relation_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.relation_id(value json) returns meta.relation_id as $$
    select row(row(value->'schema_id'->>'name'), value->>'name')::meta.relation_id
$$ immutable language sql;


create cast (json as meta.relation_id)
with function meta.relation_id(json)
as assignment;


/*
 * Function: urldecode_arr
 * Author: Marc Mamin
 * Source: PostgreSQL Tricks (http://postgres.cz/wiki/postgresql_sql_tricks#function_for_decoding_of_url_code)
 * Decode URLs
 */
create function meta.urldecode_arr(url text)
returns text as $$
begin
  return
   (with str as (select case when $1 ~ '^%[0-9a-fa-f][0-9a-fa-f]' then array[''] end
                                      || regexp_split_to_array ($1, '(%[0-9a-fa-f][0-9a-fa-f])+', 'i') plain,
                       array(select (regexp_matches ($1, '((?:%[0-9a-fa-f][0-9a-fa-f])+)', 'gi'))[1]) encoded)
     select  coalesce(string_agg(plain[i] || coalesce( convert_from(decode(replace(encoded[i], '%',''), 'hex'), 'utf8'), ''), ''), $1)
        from str,
             (select  generate_series(1, array_upper(encoded,1) + 2) i from str) blah);
end
$$ language plpgsql immutable strict;


create function meta.relation_id(value text) returns meta.relation_id as $$
select meta.relation_id(
    meta.urldecode_arr((string_to_array(value, '/'))[1]::text), -- Schema name
    meta.urldecode_arr((string_to_array(value, '/'))[2]::text) -- Relation name
)
$$ immutable language sql;


create cast (text as meta.relation_id)
with function meta.relation_id(text)
as assignment;


create function meta.text(value meta.relation_id) returns text as $$
select (value).schema_id.name || '/' || value.name
$$ immutable language sql;


create cast (meta.relation_id as text)
with function meta.text(meta.relation_id)
as assignment;



/******************************************************************************
 * meta.column_id
 *****************************************************************************/

create type meta.column_id as (
    relation_id meta.relation_id,
    name text
);


create function meta.column_id(schema_name text, relation_name text, name text) returns meta.column_id as $$
    select row(row(row(schema_name), relation_name), name)::meta.column_id;
$$ language sql;


create function meta.eq(
    leftarg meta.column_id,
    rightarg json
) returns boolean as $$
    select (leftarg).relation_id = rightarg->'relation_id' and
           (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.column_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.column_id(value json) returns meta.column_id as $$
    select row(row(row(value->'relation_id'->'schema_id'->>'name'), value->'relation_id'->>'name'), value->>'name')::meta.column_id
$$ immutable language sql;


create cast (json as meta.column_id)
with function meta.column_id(json)
as assignment;




/******************************************************************************
 * meta.foreign_key_id
 *****************************************************************************/

create type meta.foreign_key_id as (
    relation_id meta.relation_id,
    name text
);


create function meta.foreign_key_id(schema_name text, relation_name text, name text) returns meta.foreign_key_id as $$
    select row(row(row(schema_name), relation_name), name)::meta.foreign_key_id
$$ language sql;


create function meta.eq(
    leftarg meta.foreign_key_id,
    rightarg json
) returns boolean as $$
    select (leftarg).relation_id = rightarg->'relation_id' and
           (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.foreign_key_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.foreign_key_id(value json) returns meta.foreign_key_id as $$
    select row(row(row(value->'relation_id'->'schema_id'->>'name'), value->'relation_id'->>'name'), value->>'name')::meta.foreign_key_id
$$ immutable language sql;


create cast (json as meta.foreign_key_id)
with function meta.foreign_key_id(json)
as assignment;



/******************************************************************************
 * meta.row_id
 *****************************************************************************/

create type meta.row_id as (
    pk_column_id meta.column_id,
    pk_value text
);

create function meta.row_id(schema_name text, relation_name text, pk_column_name text, pk_value text) returns meta.row_id as $$
    select row(
           row(row(row(schema_name), relation_name), pk_column_name),
               pk_value
           )::meta.row_id
    -- TODO: check for not existing row ?  no.
$$ language sql;

create function exec(statements text[]) returns setof record as $$
   declare
       statement text;
   begin
       foreach statement in array statements loop
           -- raise info 'EXEC statement: %', statement;
           return query execute statement;
       end loop;
    end;
$$ language plpgsql volatile returns null on null input;


create function meta.eq(
    leftarg meta.row_id,
    rightarg json
) returns boolean as $$
    select (leftarg).pk_column_id = rightarg->'column_id' and
           (leftarg).pk_value = rightarg->>'pk_value';
$$ language sql;

create operator = (
    leftarg = meta.row_id,
    rightarg = json,
    procedure = meta.eq
);

create function meta.row_id(value json) returns meta.row_id as $$
    select
    row(
        meta.column_id(value->'pk_column_id'),
        value->>'pk_value'
    )::meta.row_id
$$ immutable language sql;

create cast (json as meta.row_id)
with function meta.row_id(json)
as assignment;


-- returns an actual row, given a row_id
create or replace function meta.row_id_to_json(row_id meta.row_id, out row_json json) as $$
begin

    execute 'with r as (select * from ' || quote_ident ((row_id).pk_column_id.relation_id.schema_id.name) || '.'
                             || quote_ident ((row_id).pk_column_id.relation_id.name)
                             || ' where ' || quote_ident ((row_id.pk_column_id).name)
                             || ' = ' || quote_literal (row_id.pk_value) || ') SELECT row_to_json(r.*) FROM r'
        into row_json;
    return;

end;
$$ language plpgsql;


create or replace function meta.row_id_as_json(row_id meta.row_id, out _row_id json) as $$
-- {"pk_value":"de94da7f-3997-4df9-844d-44635e165fea","relation_id":{"schema_id":{"name":"bundle"},"name":"rowset_row"}} zzzz
begin
    execute format ('select ''{"pk_value":"%s","pk_column_id":{"name": "%s", "relation_id": {"name":"%s", "schema_id":{"name":"%s"}}}}''::json',
    (row_id).pk_value,
    ((row_id).pk_column_id).name,
    (((row_id).pk_column_id).relation_id).name,
    ((((row_id).pk_column_id).relation_id).schema_id).name
    ) into _row_id;
end;
$$ language plpgsql;

create cast (meta.row_id as json)
    with function meta.row_id_as_json(meta.row_id)
as assignment;



/*
 * TODO: Audit this.
 * Seems like row_id should have pk_column_name in it instead of looking stuff
 * up.  Seems like we should be using quote_ident since idents can contain
 * slashes.  Actually kind of our own version of quote_ident that is
 * slash-aware.
 */

create or replace function meta.row_id(value text) returns meta.row_id as $$
declare
    parts text[];
    schema_name text;
    relation_name text;
    pk_value text;
    pk_column_name text;
begin
    select string_to_array(value, '/') into parts;
    select meta.urldecode_arr(parts[1]::text) into schema_name;
    select meta.urldecode_arr(parts[2]::text) into relation_name;
    select meta.urldecode_arr(parts[3]::text) into pk_value;

    select c.column_name as name
    from information_schema.columns c
        left join information_schema.table_constraints t
              on t.table_catalog = c.table_catalog and
                 t.table_schema = c.table_schema and
                 t.table_name = c.table_name and
                 t.constraint_type = 'PRIMARY KEY'
        left join information_schema.key_column_usage k
              on k.constraint_catalog = t.constraint_catalog and
                 k.constraint_schema = t.constraint_schema and
                 k.constraint_name = t.constraint_name and
                 k.column_name = c.column_name
    where c.table_schema = schema_name and c.table_name = relation_name
            and k.column_name is not null or (c.table_schema = 'meta' and c.column_name = 'id') -- is this the primary_key
    into pk_column_name;

    return meta.row_id(
        schema_name,
        relation_name,
        pk_column_name,
        pk_value
    );

end;
$$ immutable language plpgsql;


create cast (text as meta.row_id)
with function meta.row_id(text)
as assignment;


create function meta.text(value meta.row_id) returns text as $$
select (value).pk_column_id.relation_id.schema_id.name || '/' ||
    (value).pk_column_id.relation_id.name || '/' ||
    value.pk_value
$$ immutable language sql;


create cast (meta.row_id as text)
with function meta.text(meta.row_id)
as assignment;



/******************************************************************************
 * meta.field_id
 *****************************************************************************/

create type meta.field_id as (
    row_id meta.row_id,
    column_id meta.column_id
);

create function meta.field_id(schema_name text, relation_name text, pk_column_name text, pk_value text, column_name text) returns meta.field_id as $$
    select row(
               meta.row_id(schema_name, relation_name, pk_column_name, pk_value),
               meta.column_id(schema_name, relation_name, column_name)
           )::meta.field_id
$$ language sql;

create or replace function meta.field_id_literal_value(field_id meta.field_id) returns text as $$
declare
    literal_value text;
begin
    execute 'select ' || quote_ident(((field_id).column_id).name) || '::text'
            || ' from ' || quote_ident((field_id::meta.schema_id).name) || '.'
                        || quote_ident((field_id::meta.relation_id).name)
            || ' where ' || quote_ident((((field_id).row_id).pk_column_id).name)
                         || '::text =' || quote_literal(((field_id).row_id).pk_value)
    into literal_value;

    return literal_value;
exception when others then return null;
end
$$ language plpgsql;

create or replace function meta.row_id_to_json(row_id meta.row_id) returns json as $$
declare
    json_value json;
begin
    execute 'select row_to_json(r) from (select * from '
            || quote_ident((row_id::meta.schema_id).name) || '.'
            || quote_ident((row_id::meta.relation_id).name)
            || ' where ' || quote_ident(((row_id).pk_column_id).name)
                         || '::text =' || quote_literal((row_id).pk_value)
            || ') r'
    into json_value;

    return json_value;
exception when others then return null;
end
$$ language plpgsql;


create function meta.eq(
    leftarg meta.field_id,
    rightarg json
) returns boolean as $$
    select (leftarg).row_id = rightarg->'row_id' and
           (leftarg).column_id = rightarg->'column_id';
$$ language sql;


create operator = (
    leftarg = meta.field_id,
    rightarg = json,
    procedure = meta.eq
);

create function meta.field_id(value json) returns meta.field_id as $$
    select row(meta.row_id(value->'row_id'), meta.column_id(value->'column_id'))::meta.field_id
$$ immutable language sql;


create cast (json as meta.field_id)
with function meta.field_id(json)
as assignment;


create or replace function meta.field_id(value text) returns meta.field_id as $$
declare
    parts text[];
    schema_name text;
    relation_name text;
    pk_value text;
    column_name text;
    pk_column_name text;
begin
    select string_to_array(value, '/') into parts;
    select meta.urldecode_arr(parts[1]::text) into schema_name;
    select meta.urldecode_arr(parts[2]::text) into relation_name;
    select meta.urldecode_arr(parts[3]::text) into pk_value;
    select meta.urldecode_arr(parts[4]::text) into column_name;

    select c.column_name as name
    from information_schema.columns c
    left join information_schema.table_constraints t
          on t.table_catalog = c.table_catalog and
             t.table_schema = c.table_schema and
             t.table_name = c.table_name and
             t.constraint_type = 'PRIMARY KEY'
    left join information_schema.key_column_usage k
          on k.constraint_catalog = t.constraint_catalog and
             k.constraint_schema = t.constraint_schema and
             k.constraint_name = t.constraint_name and
             k.column_name = c.column_name
    where c.table_schema = schema_name and c.table_name = relation_name
            and k.column_name is not null or (c.table_schema = 'meta' and c.column_name = 'id') -- is this the primary_key
    into pk_column_name;

    return meta.field_id(
        schema_name,
        relation_name,
        pk_column_name,
        pk_value,
        column_name
    );

end;
$$ immutable language plpgsql;


create cast (text as meta.field_id)
with function meta.field_id(text)
as assignment;


create function meta.text(value meta.field_id) returns text as $$
select (value).column_id.relation_id.schema_id.name || '/' ||
    (value).column_id.relation_id.name || '/' ||
    (value).row_id.pk_value || '/' ||
    (value).column_id.name
$$ immutable language sql;


create cast (meta.field_id as text)
with function meta.text(meta.field_id)
as assignment;


/******************************************************************************
 * meta.function_id
 *****************************************************************************/

/* FIXME not needed in PG 9.4 */
create function meta.json_array_elements_text(json json, out value text) returns setof text as $$
    select json->>i
    from generate_series(0, json_array_length(json)-1) as i
$$ language sql immutable;


create type meta.function_id as (
    schema_id meta.schema_id,
    name text,
    parameters text[]
);


create function meta.function_id(schema_name text, name text, parameters text[]) returns meta.function_id as $$
    select row(row(schema_name), name, parameters)::meta.function_id;
$$ language sql;


create function meta.eq(
    leftarg meta.function_id,
    rightarg json
) returns boolean as $$
    select (leftarg).schema_id = rightarg->'schema_id' and
           (leftarg).name = rightarg->>'name' and
           (leftarg).parameters = (
               select array_agg(value)
               from meta.json_array_elements_text(rightarg->'parameters')
           );
$$ language sql;


create operator = (
    leftarg = meta.function_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.function_id(value json) returns meta.function_id as $$
    select row(row(value->'schema_id'->>'name'), value->>'name',
           (select array_agg(value) from json_array_elements(value->'parameters')))::meta.function_id
$$ immutable language sql;


create cast (json as meta.function_id)
with function meta.function_id(json)
as assignment;


create or replace function meta.function_id(value text) returns meta.function_id as $$
select meta.function_id(
    meta.urldecode_arr((string_to_array(value, '/'))[1]::text), -- schema name
    meta.urldecode_arr((string_to_array(value, '/'))[2]::text), -- function name
    meta.urldecode_arr((string_to_array(value, '/'))[3]::text)::text[] -- array of ordered parameter types, e.g. {uuid,text,text}
)
$$ immutable language sql;


create cast (text as meta.function_id)
with function meta.function_id(text)
as assignment;


create function meta.text(value meta.function_id) returns text as $$
select (value).schema_id.name || '/' ||
    (value).name || '/' ||
    (value).parameters::text
$$ immutable language sql;


create cast (meta.function_id as text)
with function meta.text(meta.function_id)
as assignment;


/******************************************************************************
 * meta.trigger_id
 *****************************************************************************/

create type meta.trigger_id as (
    relation_id meta.relation_id,
    name text
);


create function meta.trigger_id(schema_name text, relation_name text, name text) returns meta.trigger_id as $$
    select row(row(row(schema_name), relation_name), name)::meta.trigger_id;
$$ language sql;



/******************************************************************************
 * meta.role_id
 *****************************************************************************/

create type meta.role_id as (
    name text
);


create function meta.role_id(name text) returns meta.role_id as $$
    select row(name)::meta.role_id;
$$ language sql;


create function meta.eq(
    leftarg meta.role_id,
    rightarg json
) returns boolean as $$
    select (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.role_id,
    rightarg = json,
    procedure = meta.eq
);


create cast (text as meta.role_id)
with function meta.role_id(text)
as assignment;


create function meta.role_id(value json) returns meta.role_id as $$
    select row(value->>'name')::meta.role_id
$$ immutable language sql;


create cast (json as meta.role_id)
with function meta.role_id(json)
as assignment;


/******************************************************************************
 * meta.policy_id
 *****************************************************************************/
create type meta.policy_id as (
    relation_id meta.relation_id,
    name text
);


create function meta.policy_id(schema_name text, relation_name text, name text) returns meta.policy_id as $$
    select row(row(row(schema_name), relation_name), name)::meta.policy_id;
$$ language sql;


create function meta.eq(
    leftarg meta.policy_id,
    rightarg json
) returns boolean as $$
    select (leftarg).relation_id::meta.relation_id = (rightarg->'relation_id')::meta.relation_id and
           (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.policy_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.policy_id(value json) returns meta.policy_id as $$
    select row(row(row(value->'relation_id'->'schema_id'->>'name'), value->'relation_id'->>'name'), value->>'name')::meta.policy_id
$$ immutable language sql;


create cast (json as meta.policy_id)
with function meta.policy_id(json)
as assignment;


create function meta.policy_id(relation_id meta.relation_id, name text) returns meta.policy_id as $$
    select row(relation_id, name)::meta.policy_id;
$$ language sql;


/******************************************************************************
 * meta.siuda
 *****************************************************************************/
create type meta.siuda as enum ('select', 'insert', 'update', 'delete', 'all');


create function meta.siuda(c char) returns meta.siuda as $$
begin
    case c
        when 'r' then
            return 'select'::meta.siuda;
        when 'a' then
            return 'insert'::meta.siuda;
        when 'w' then
            return 'update'::meta.siuda;
        when 'd' then
            return 'delete'::meta.siuda;
        when '*' then
            return 'all'::meta.siuda;
    end case;
end;
$$ immutable language plpgsql;


create cast (char as meta.siuda)
with function meta.siuda(char)
as assignment;


/******************************************************************************
 * meta.table_privilege_id
 *****************************************************************************/
create type meta.table_privilege_id as (
    relation_id meta.relation_id,
    role_id meta.role_id,
    type text
);


create function meta.table_privilege_id(schema_name text, relation_name text, role_name text, type text) returns meta.table_privilege_id as $$
    select row(row(row(schema_name), relation_name), row(role_name), type)::meta.table_privilege_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.table_privilege_id,
    rightarg json
) returns boolean as $$
    select (leftarg).relation_id = rightarg->'relation_id' and
           (leftarg).role_id = rightarg->'role_id' and
           (leftarg).type = rightarg->>'type';
$$ language sql;


create operator = (
    leftarg = meta.table_privilege_id,
    rightarg = json,
    procedure = meta.eq
);


create function meta.table_privilege_id(value json) returns meta.table_privilege_id as $$
    select row(row(row(value->'relation_id'->'schema_id'->>'name'), value->'relation_id'->>'name'), row(value->'role_id'->>'name'), value->>'type')::meta.table_privilege_id
$$ immutable language sql;


create cast (json as meta.table_privilege_id)
with function meta.table_privilege_id(json)
as assignment;


/******************************************************************************
 * meta.connection_id
 *****************************************************************************/

create type meta.connection_id as (
    pid integer,
    connection_start timestamp with time zone
);


create function meta.connection_id(pid integer, connection_start timestamp with time zone) returns meta.connection_id as $$
    select row(pid, connection_start)::meta.connection_id;
$$ language sql;



/******************************************************************************
 * meta.constraint_id
 *****************************************************************************/

create type meta.constraint_id as (
    table_id meta.relation_id,
    name text
);

create function meta.constraint_id(schema_name text, relation_name text, name text) returns meta.constraint_id as $$
    select row(row(row(schema_name), relation_name), name)::meta.constraint_id;
$$ language sql;



/******************************************************************************
 * meta.extension_id
 *****************************************************************************/

create type meta.extension_id as (
    name text
);


create function meta.extension_id(
    name text
) returns meta.extension_id as $$
    select row(name)::meta.extension_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.extension_id,
    rightarg json
) returns boolean as $$
    select (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.extension_id,
    rightarg = json,
    procedure = meta.eq
);



/******************************************************************************
 * meta.foreign_data_wrapper_id
 *****************************************************************************/

create type meta.foreign_data_wrapper_id as (
    name text
);


create function meta.foreign_data_wrapper_id(
    name text
) returns meta.foreign_data_wrapper_id as $$
    select row(name)::meta.foreign_data_wrapper_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.foreign_data_wrapper_id,
    rightarg json
) returns boolean as $$
    select (leftarg).name = rightarg->>'name';
$$ language sql;


create operator = (
    leftarg = meta.foreign_data_wrapper_id,
    rightarg = json,
    procedure = meta.eq
);



/******************************************************************************
 * meta.foreign_server_id
 *****************************************************************************/

create type meta.foreign_server_id as (
    name text
);


create function meta.foreign_server_id(
    name text
) returns meta.foreign_server_id as $$
    select row(name)::meta.foreign_server_id
$$ language sql immutable;


create function meta.eq(
    leftarg meta.foreign_server_id,
    rightarg json
) returns boolean as $$
    select (leftarg).name = rightarg->>'name';
$$ language sql immutable;


create operator = (
    leftarg = meta.foreign_server_id,
    rightarg = json,
    procedure = meta.eq
);



/******************************************************************************
 * Casts between meta-types
 *****************************************************************************/
-- relation to schema
create function meta.relation_id_to_schema_id(in meta.relation_id, out meta.schema_id) as $$
    select $1.schema_id
$$
language sql;

create cast (relation_id as schema_id)
    with function relation_id_to_schema_id(relation_id) as assignment;


-- typ to schema
create function meta.type_id_to_schema_id(in meta.type_id, out meta.schema_id) as $$
    select $1.schema_id
$$
language sql;

create cast (type_id as schema_id)
    with function type_id_to_schema_id(type_id) as assignment;


-- column to relation
create function column_id_to_relation_id(in meta.column_id, out meta.relation_id) as $$
    select $1.relation_id
$$
language sql;

create cast (column_id as relation_id)
    with function column_id_to_relation_id(column_id) as assignment;


-- column to schema
create function schema_id(in meta.column_id, out meta.schema_id) as $$
    select $1.relation_id.schema_id
$$
language sql;

create cast (column_id as schema_id)
    with function schema_id(column_id) as assignment;


-- row to relation
create function row_id_to_relation_id(in meta.row_id, out meta.relation_id) as $$
    select ($1.pk_column_id).relation_id
$$
language sql;

create cast (row_id as relation_id)
    with function row_id_to_relation_id(row_id) as assignment;


-- row to schema
create function schema_id(in meta.row_id, out meta.schema_id) as $$
    select (($1.pk_column_id).relation_id).schema_id
$$
language sql;

create cast (row_id as schema_id)
    with function schema_id(row_id) as assignment;


-- field to relation
create function relation_id(in meta.field_id, out meta.relation_id) as $$
       select ($1.column_id).relation_id
       $$
       language sql;

create cast (field_id as relation_id)
       with function relation_id(field_id) as assignment;


-- field to schema
create function schema_id(in meta.field_id, out meta.schema_id) as $$
       select (($1.column_id).relation_id).schema_id
       $$
       language sql;

create cast (field_id as schema_id)
       with function schema_id(field_id) as assignment;


-- field to column
/* we can't make these, because
ERR0R:  "column_id" is already an attribute of type field_id

create function column_id(in meta.field_id, out meta.column_id) as $$
       select ($1.column_id)
       $$
       language sql;

create cast (field_id as column_id)
       with function column_id(field_id) as assignment;

*/

-- function to schema
create function function_id_to_schema_id(in meta.function_id, out meta.schema_id) as $$
       select ($1.schema_id)
       $$
       language sql;

create cast (function_id as schema_id)
       with function function_id_to_schema_id(function_id) as assignment;
/*******************************************************************************
 * Meta Catalog
 * A writable system catalog for PostgreSQL
 *
 * Copyright (c) 2019 - Aquameta - http://aquameta.org/
 ******************************************************************************/

/******************************************************************************
 * utility functions
 *****************************************************************************/

create function meta.require_all(fields public.hstore, required_fields text[]) returns void as $$
    declare
        f record;

    begin
        -- hstore needs this
        set local search_path=public,meta;
        for f in select unnest(required_fields) as field_name loop
            if (fields->f.field_name) is null then
                raise exception '% is a required field.', f.field_name;
            end if;
        end loop;
    end;
$$ language plpgsql;


create function meta.require_one(fields public.hstore, required_fields text[]) returns void as $$
    declare
        f record;

    begin
        -- hstore needs this
        set local search_path=public,meta;
        for f in select unnest(required_fields) as field_name loop
            if (fields->f.field_name) is not null then
                return;
            end if;
        end loop;

        raise exception 'One of the fields % is required.', required_fields;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.schema
 *****************************************************************************/

create view meta.schema as
    select row(schema_name)::meta.schema_id as id,
           schema_name::text as name
    from information_schema.schemata;


create function meta.stmt_schema_create(name text) returns text as $$
    select 'create schema ' || quote_ident(name)
$$ language sql;


create function meta.stmt_schema_rename(old_name text, new_name text) returns text as $$
    select 'alter schema ' || quote_ident(old_name) || ' rename to ' || quote_ident(new_name);
$$ language sql;


create function meta.stmt_schema_drop(name text) returns text as $$
    select 'drop schema ' || quote_ident(name);
$$ language sql;


create function meta.schema_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        execute meta.stmt_schema_create(NEW.name);
        NEW.id := row(NEW.name)::meta.schema_id;
        return NEW;
    end;
$$ language plpgsql;


create function meta.schema_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        if OLD.name is distinct from NEW.name then
            execute meta.stmt_schema_rename(OLD.name, NEW.name);
        end if;
        return NEW;
    end;
$$ language plpgsql;


create function meta.schema_delete() returns trigger as $$
    begin
        execute meta.stmt_schema_drop(OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.type
 *****************************************************************************/
create view meta.type as
select
    meta.type_id(n.nspname, pg_catalog.format_type(t.oid, NULL)) as id,
    n.nspname::text as "schema_name",
    pg_catalog.format_type(t.oid, NULL)::text as "name",
    case when c.relkind = 'c' then true else false end as "composite",
    pg_catalog.obj_description(t.oid, 'pg_type') as "description"
from pg_catalog.pg_type t
     left join pg_catalog.pg_namespace n on n.oid = t.typnamespace
     left join pg_catalog.pg_class c on c.oid = t.typrelid
where (t.typrelid = 0 or c.relkind = 'c')
  and not exists(select 1 from pg_catalog.pg_type el where el.oid = t.typelem and el.typarray = t.oid)
  and pg_catalog.pg_type_is_visible(t.oid)
order by 1, 2;





/******************************************************************************
 * meta.cast
 *****************************************************************************/
create view meta.cast as
--TODO
SELECT meta.cast_id(ts.typname, pg_catalog.format_type(castsource, NULL),tt.typname, pg_catalog.format_type(casttarget, NULL)) as id,
       pg_catalog.format_type(castsource, NULL) AS "source type",
       pg_catalog.format_type(casttarget, NULL) AS "target type",
       (CASE WHEN castfunc = 0 THEN '(binary coercible)'
            ELSE p.proname
       END)::text as "function",
       CASE WHEN c.castcontext = 'e' THEN 'no'
           WHEN c.castcontext = 'a' THEN 'in assignment'
        ELSE 'yes'
       END as "implicit?" FROM pg_catalog.pg_cast c LEFT JOIN pg_catalog.pg_proc p
     ON c.castfunc = p.oid
     LEFT JOIN pg_catalog.pg_type ts
     ON c.castsource = ts.oid
     LEFT JOIN pg_catalog.pg_namespace ns
     ON ns.oid = ts.typnamespace
     LEFT JOIN pg_catalog.pg_type tt
     ON c.casttarget = tt.oid
     LEFT JOIN pg_catalog.pg_namespace nt
     ON nt.oid = tt.typnamespace
WHERE ( (true  AND pg_catalog.pg_type_is_visible(ts.oid)
    ) OR (true  AND pg_catalog.pg_type_is_visible(tt.oid)
) )
ORDER BY 1, 2;

/******************************************************************************
 * meta.operator
 *****************************************************************************/
create view meta.operator as
SELECT meta.operator_id(n.nspname, o.oprname, trns.nspname, tr.typname, trns.nspname, tr.typname) as id,
    n.nspname::text as schema_name,
    o.oprname::text as name,
    CASE WHEN o.oprkind='l' THEN NULL ELSE pg_catalog.format_type(o.oprleft, NULL) END AS "Left arg type",
    CASE WHEN o.oprkind='r' THEN NULL ELSE pg_catalog.format_type(o.oprright, NULL) END AS "Right arg type",
    pg_catalog.format_type(o.oprresult, NULL) AS "Result type",
    coalesce(pg_catalog.obj_description(o.oid, 'pg_operator'),
        pg_catalog.obj_description(o.oprcode, 'pg_proc')) AS "Description"
FROM pg_catalog.pg_operator o
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = o.oprnamespace
    JOIN pg_catalog.pg_type tl ON o.oprleft = tl.oid
    JOIN pg_catalog.pg_namespace tlns on tl.typnamespace = tlns.oid
    JOIN pg_catalog.pg_type tr ON o.oprleft = tr.oid
    JOIN pg_catalog.pg_namespace trns on tr.typnamespace = trns.oid
WHERE n.nspname <> 'pg_catalog'
    AND n.nspname <> 'information_schema'
    AND pg_catalog.pg_operator_is_visible(o.oid)
ORDER BY 1, 2, 3, 4;


/******************************************************************************
 * meta.sequence
 *****************************************************************************/
create view meta.sequence as
    select meta.sequence_id(sequence_schema, sequence_name) as id,
           meta.schema_id(sequence_schema) as schema_id,
           sequence_schema::text as schema_name,
           sequence_name::text as name,
           start_value::bigint,
           minimum_value::bigint,
           maximum_value::bigint,
           increment::bigint,
           cycle_option = 'YES' as cycle

    from information_schema.sequences;


create function meta.stmt_sequence_create(
    schema_name text,
    name text,
    start_value bigint,
    minimum_value bigint,
    maximum_value bigint,
    increment bigint,
    cycle boolean
) returns text as $$
    select 'create sequence ' || quote_ident(schema_name) || '.' || quote_ident(name)
           || coalesce(' increment ' || increment, '')
           || coalesce(' minvalue ' || minimum_value, ' no minvalue ')
           || coalesce(' maxvalue ' || maximum_value, ' no maxvalue ')
           || coalesce(' start ' || start_value, '')
           || case cycle when true then ' cycle '
                         else ' no cycle '
              end;
$$ language sql;


create function meta.stmt_sequence_set_schema(
    schema_name text,
    name text,
    new_schema_name text
) returns text as $$
    select 'alter sequence ' || quote_ident(schema_name) || '.' || quote_ident(name)
           || ' set schema ' || quote_ident(new_schema_name);
$$ language sql immutable;


create function meta.stmt_sequence_rename(
    schema_name text,
    name text,
    new_name text
) returns text as $$
    select 'alter sequence ' || quote_ident(schema_name) || '.' || quote_ident(name)
           || ' rename to ' || quote_ident(new_name);
$$ language sql immutable;


create function meta.stmt_sequence_alter(
    schema_name text,
    name text,
    start_value bigint,
    minimum_value bigint,
    maximum_value bigint,
    increment bigint,
    cycle boolean
) returns text as $$
    select 'alter sequence ' || quote_ident(schema_name) || '.' || quote_ident(name)
           || coalesce(' increment ' || increment, '')
           || coalesce(' minvalue ' || minimum_value, ' no minvalue ')
           || coalesce(' maxvalue ' || maximum_value, ' no maxvalue ')
           || coalesce(' start ' || start_value, '')
           || case cycle when true then ' cycle '
                         else ' no cycle '
              end;
$$ language sql;


create function meta.stmt_sequence_drop(schema_name text, name text) returns text as $$
    select 'drop sequence ' || quote_ident(schema_name) || '.' || quote_ident(name);
$$ language sql;


create function meta.sequence_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        execute meta.stmt_sequence_create(
            coalesce(NEW.schema_name, (NEW.schema_id).name),
            NEW.name,
            NEW.start_value,
            NEW.minimum_value,
            NEW.maximum_value,
            NEW.increment,
            NEW.cycle
        );

        NEW.id := meta.sequence_id(
            coalesce(NEW.schema_name, (NEW.schema_id).name),
            NEW.name
        );

        return NEW;
    end;
$$ language plpgsql;


create function meta.sequence_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        if NEW.schema_id != OLD.schema_id or OLD.schema_name != NEW.schema_name then
            execute meta.stmt_sequence_set_schema(OLD.schema_name, OLD.name, coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name));
        end if;

        if NEW.name != OLD.name then
            execute meta.stmt_sequence_rename(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), OLD.name, NEW.name);
        end if;

        execute meta.stmt_sequence_alter(
            coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name),
            NEW.name,
            NEW.start_value,
            NEW.minimum_value,
            NEW.maximum_value,
            NEW.increment,
            NEW.cycle
        );

        return NEW;
    end;
$$ language plpgsql;


create function meta.sequence_delete() returns trigger as $$
    begin
        execute meta.stmt_sequence_drop(OLD.schema_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.table
 *****************************************************************************/
create view meta.table as
    select row(row(schemaname), tablename)::meta.relation_id as id,
           row(schemaname)::meta.schema_id as schema_id,
           schemaname::text as schema_name,
           tablename::text as name,
           rowsecurity as rowsecurity
    /*
    -- going from pg_catalog.pg_tables instead, so we can get rowsecurity
    from information_schema.tables
    where table_type = 'BASE TABLE';
    */
    from pg_catalog.pg_tables;


create function meta.stmt_table_create(schema_name text, table_name text) returns text as $$
    select 'create table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || '()'
$$ language sql;


create function meta.stmt_table_set_schema(schema_name text, table_name text, new_schema_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' set schema ' || quote_ident(new_schema_name);
$$ language sql;

create function meta.stmt_table_enable_rowsecurity(schema_name text, table_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' enable row level security'
$$ language sql;

create function meta.stmt_table_disable_rowsecurity(schema_name text, table_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' disable row level security'
$$ language sql;

create function meta.stmt_table_rename(schema_name text, table_name text, new_table_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' rename to ' || quote_ident(new_table_name);
$$ language sql;


create function meta.stmt_table_drop(schema_name text, table_name text) returns text as $$
    select 'drop table ' || quote_ident(schema_name) || '.' || quote_ident(table_name);
$$ language sql;


create function meta.table_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);
        execute meta.stmt_table_create(coalesce(NEW.schema_name, (NEW.schema_id).name),  NEW.name);
        if NEW.rowsecurity = true then
            execute meta.stmt_table_enable_rowsecurity(NEW.schema_name, NEW.name);
        end if;

        NEW.id := row(row(coalesce(NEW.schema_name, (NEW.schema_id).name)), NEW.name)::meta.relation_id;
        return NEW;
    end;
$$ language plpgsql;


create function meta.table_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        if NEW.schema_id != OLD.schema_id or OLD.schema_name != NEW.schema_name then
            execute meta.stmt_table_set_schema(OLD.schema_name, OLD.name, coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name));
        end if;

        if NEW.name != OLD.name then
            execute meta.stmt_table_rename(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), OLD.name, NEW.name);
        end if;

        if NEW.rowsecurity != OLD.rowsecurity then
            if NEW.rowsecurity = true then
                execute meta.stmt_table_enable_rowsecurity(NEW.schema_name, NEW.name);
            else
                execute meta.stmt_table_disable_rowsecurity(NEW.schema_name, NEW.name);
            end if;
        end if;
        return NEW;
    end;
$$ language plpgsql;


create function meta.table_delete() returns trigger as $$
    begin
        execute meta.stmt_table_drop(OLD.schema_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.view
 *****************************************************************************/
create view meta.view as
    select row(row(table_schema), table_name)::meta.relation_id as id,
           row(table_schema)::meta.schema_id as schema_id,
           table_schema::text as schema_name,
           table_name::text as name,
           view_definition::text as query

    from information_schema.views v;


create function meta.stmt_view_create(schema_name text, view_name text, query text) returns text as $$
    select 'create view ' || quote_ident(schema_name) || '.' || quote_ident(view_name) || ' as ' || query;
$$ language sql;


create function meta.stmt_view_set_schema(schema_name text, view_name text, new_schema_name text) returns text as $$
    select 'alter view ' || quote_ident(schema_name) || '.' || quote_ident(view_name) || ' set schema ' || quote_ident(new_schema_name);
$$ language sql;


create function meta.stmt_view_rename(schema_name text, view_name text, new_name text) returns text as $$
    select 'alter view ' || quote_ident(schema_name) || '.' || quote_ident(view_name) || ' rename to ' || quote_ident(new_name);
$$ language sql;


create function meta.stmt_view_drop(schema_name text, view_name text) returns text as $$
    select 'drop view ' || quote_ident(schema_name) || '.' || quote_ident(view_name);
$$ language sql;


create function meta.view_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'query']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        execute meta.stmt_view_create(coalesce(NEW.schema_name, (NEW.schema_id).name), NEW.name, NEW.query);

        return NEW;
    end;
$$ language plpgsql;


create function meta.view_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'query']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        if NEW.schema_id != OLD.schema_id or NEW.schema_name != OLD.schema_name then
            execute meta.stmt_view_set_schema(OLD.schema_name, OLD.name, coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name));
        end if;

        if NEW.name != OLD.name then
            execute meta.stmt_view_rename(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), OLD.name, NEW.name);
        end if;

        if NEW.query != OLD.query then
            execute meta.stmt_view_drop(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), NEW.name);
            execute meta.stmt_view_create(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), NEW.name, NEW.query);
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.view_delete() returns trigger as $$
    begin
        execute meta.stmt_view_drop(OLD.schema_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.column
 *****************************************************************************/
create view meta.relation_column as
    select meta.column_id(c.table_schema, c.table_name, c.column_name) as id,
           meta.relation_id(c.table_schema, c.table_name) as relation_id,
           c.table_schema::text as schema_name,
           c.table_name::text as relation_name,
           c.column_name::text as name,
           c.ordinal_position::integer as position,
           quote_ident(c.udt_schema) || '.' || quote_ident(c.udt_name) as type_name,
           meta.type_id (c.udt_schema, c.udt_name) as "type_id",
           (c.is_nullable = 'YES') as nullable,
           c.column_default::text as "default",
           k.column_name is not null or (c.table_schema = 'meta' and c.column_name = 'id') as primary_key

    from information_schema.columns c

    left join information_schema.table_constraints t
          on t.table_catalog = c.table_catalog and
             t.table_schema = c.table_schema and
             t.table_name = c.table_name and
             t.constraint_type = 'PRIMARY KEY'

    left join information_schema.key_column_usage k
          on k.constraint_catalog = t.constraint_catalog and
             k.constraint_schema = t.constraint_schema and
             k.constraint_name = t.constraint_name and
             k.column_name = c.column_name;

create view meta.column as
    -- select c.id, c.relation_id as table_id, c.schema_name, c.relation_name, c.name, c.position, c.type_name, c.type_id, c.nullable, c.column_default, c.primary_key
    select c.*
    from meta.table t
        join meta.relation_column c on c.relation_id = t.id;


create function meta.stmt_column_create(schema_name text, relation_name text, column_name text, type_name text, nullable boolean, "default" text, primary_key boolean) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' add column ' || quote_ident(column_name) || ' ' || type_name ||
           case when nullable then ''
                else ' not null'
           end ||
           case when "default" is not null and column_name != 'id' then (' default ' || "default" || '::' || type_name)
                else ''
           end ||
           case when primary_key then ' primary key'
                else ''
           end;
$$ language sql;


create function meta.stmt_column_rename(schema_name text, relation_name text, column_name text, new_column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' rename column ' || quote_ident(column_name) || ' to ' || quote_ident(new_column_name);
$$ language sql;


create function meta.stmt_column_add_primary_key(schema_name text, relation_name text, column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' add primary key (' || quote_ident(column_name) || ')';
$$ language sql;


create function meta.stmt_column_drop_primary_key(schema_name text, relation_name text, column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' drop constraint ' || quote_ident(column_name) || '_pkey';
$$ language sql;


create function meta.stmt_column_set_not_null(schema_name text, relation_name text, column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(column_name) || ' set not null';
$$ language sql;


create function meta.stmt_column_drop_not_null(schema_name text, relation_name text, column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(column_name) || ' drop not null';
$$ language sql;


create function meta.stmt_column_set_default(schema_name text, relation_name text, column_name text, "default" text, type_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(column_name) || ' set default ' || "default" || '::' || type_name;
$$ language sql;


create function meta.stmt_column_drop_default(schema_name text, relation_name text, column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(column_name) || ' drop default ';
$$ language sql;


create function meta.stmt_column_set_type(schema_name text, relation_name text, column_name text, type_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(column_name) || ' type ' || type_name;
$$ language sql;


create function meta.stmt_column_drop(schema_name text, relation_name text, column_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' drop column ' || quote_ident(column_name);
$$ language sql;


create function meta.column_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'type_name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'relation_name']);

        execute meta.stmt_column_create(coalesce(NEW.schema_name, ((NEW.relation_id).schema_id).name), coalesce(NEW.relation_name, (NEW.relation_id).name), NEW.name, NEW.type_name, NEW.nullable, NEW."default", NEW.primary_key);

        return NEW;
    end;
$$ language plpgsql;


create function meta.column_update() returns trigger as $$
    declare
        schema_name text;
        relation_name text;

    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'type_name', 'nullable']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'relation_name']);

        if NEW.relation_id is not null and OLD.relation_id != NEW.relation_id or
           NEW.schema_name is not null and OLD.schema_name != NEW.schema_name or
           NEW.relation_name is not null and OLD.relation_name != NEW.relation_name then

            raise exception 'Moving a column to another table is not yet supported.';
        end if;

        schema_name := OLD.schema_name;
        relation_name := OLD.relation_name;

        if NEW.name != OLD.name then
            execute meta.stmt_column_rename(schema_name, relation_name, OLD.name, NEW.name);
        end if;

        if NEW.type_name != OLD.type_name then
            execute meta.stmt_column_set_type(schema_name, relation_name, NEW.name, NEW.type_name);
        end if;

        if NEW.nullable != OLD.nullable then
            if NEW.nullable then
                execute meta.stmt_column_drop_not_null(schema_name, relation_name, NEW.name);
            else
                execute meta.stmt_column_set_not_null(schema_name, relation_name, NEW.name);
            end if;
        end if;

        if NEW."default" is distinct from OLD."default" then
            if NEW."default" is null then
                execute meta.stmt_column_drop_default(schema_name, relation_name, NEW.name);
            else
                execute meta.stmt_column_set_default(schema_name, relation_name, NEW.name, NEW."default", NEW."type_name");
            end if;
        end if;

        if NEW.primary_key != OLD.primary_key then
            if NEW.primary_key then
                execute meta.stmt_column_add_primary_key(schema_name, relation_name, NEW.name);
            else
                execute meta.stmt_column_drop_primary_key(schema_name, relation_name, NEW.name);
            end if;
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.column_delete() returns trigger as $$
    begin
        execute meta.stmt_column_drop(OLD.schema_name, OLD.relation_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.relation
 *****************************************************************************/
create view meta.relation as
    select row(row(t.table_schema), t.table_name)::meta.relation_id as id,
           row(t.table_schema)::meta.schema_id as schema_id,
           t.table_schema::text as schema_name,
           t.table_name::text as name,
           t.table_type::text as "type",
           nullif(array_agg(c.id), array[null]::meta.column_id[]) as primary_key_column_ids,
           nullif(array_agg(c.name::text), array[null]::text[]) as primary_key_column_names

    from information_schema.tables t

    left join meta.relation_column c
           on c.relation_id = row(row(t.table_schema), t.table_name)::meta.relation_id and c.primary_key

    group by t.table_schema, t.table_name, t.table_type;


/******************************************************************************
 * meta.foreign_key
 *****************************************************************************/
create view meta.foreign_key as
    select row(row(row(tc.table_schema), tc.table_name), tc.constraint_name)::meta.foreign_key_id as id,
           row(row(tc.table_schema), tc.table_name)::meta.relation_id as table_id,
           tc.table_schema::text as schema_name,
           tc.table_name::text as table_name,
           tc.constraint_name::text as name,
           array_agg(row(row(row(kcu.table_schema), kcu.table_name), kcu.column_name)::meta.column_id) as from_column_ids,
           array_agg(row(row(row(ccu.table_schema), ccu.table_name), ccu.column_name)::meta.column_id) as to_column_ids,
           update_rule::text as on_update,
           delete_rule::text as on_delete

    from information_schema.table_constraints tc

    inner join information_schema.referential_constraints rc
            on rc.constraint_catalog = tc.constraint_catalog and
               rc.constraint_schema = tc.constraint_schema and
               rc.constraint_name = tc.constraint_name

    inner join information_schema.constraint_column_usage ccu
            on ccu.constraint_catalog = tc.constraint_catalog and
               ccu.constraint_schema = tc.constraint_schema and
               ccu.constraint_name = tc.constraint_name

    inner join information_schema.key_column_usage kcu
            on kcu.constraint_catalog = tc.constraint_catalog and
               kcu.constraint_schema = tc.constraint_schema and
               kcu.constraint_name = tc.constraint_name

    where constraint_type = 'FOREIGN KEY'

    group by tc.table_schema, tc.table_name, tc.constraint_name, update_rule, delete_rule;


create function meta.stmt_foreign_key_create(schema_name text, table_name text, constraint_name text, from_column_ids meta.column_id[], to_column_ids meta.column_id[], on_update text, on_delete text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' add constraint ' || quote_ident(constraint_name) ||
           ' foreign key (' || (
               select string_agg(name, ', ')
               from meta."column"
               where id = any(from_column_ids)

           ) || ') references ' || (((to_column_ids[1]).relation_id).schema_id).name || '.' || ((to_column_ids[1]).relation_id).name || (
               select '(' || string_agg(c.name, ', ') || ')'
               from meta."column" c
               where c.id = any(to_column_ids)

           ) || ' on update ' || on_update
             || ' on delete ' || on_delete;
$$ language sql;


create function meta.stmt_foreign_key_drop(schema_name text, table_name text, constraint_name text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' drop constraint ' || quote_ident(constraint_name);
$$ language sql;


create function meta.foreign_key_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'from_column_ids', 'to_column_ids', 'on_update', 'on_delete']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);

        execute meta.stmt_foreign_key_create(
                    coalesce(NEW.schema_name, ((NEW.table_id).schema_id).name),
                    coalesce(NEW.table_name, (NEW.table_id).name),
                    NEW.name, NEW.from_column_ids, NEW.to_column_ids, NEW.on_update, NEW.on_delete
                );
        return NEW;

    exception
        when null_value_not_allowed then
            raise exception 'A provided column_id was not found in meta.column.';
    end;
$$ language plpgsql;


create function meta.foreign_key_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'from_column_ids', 'to_column_ids', 'on_update', 'on_delete']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);

        execute meta.stmt_foreign_key_drop(OLD.schema_name, OLD.table_name, OLD.name);
        execute meta.stmt_foreign_key_create(
                    coalesce(NEW.schema_name, ((NEW.table_id).schema_id).name),
                    coalesce(NEW.table_name, (NEW.table_id).name),
                    NEW.name, NEW.from_column_ids, NEW.to_column_ids, NEW.on_update, NEW.on_delete
                );
        return NEW;

    exception
        when null_value_not_allowed then
            raise exception 'A provided column_id was not found in meta.column.';
    end;
$$ language plpgsql;


create function meta.foreign_key_delete() returns trigger as $$
    begin
        execute meta.stmt_foreign_key_drop(OLD.schema_name, OLD.table_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.row_id
 *****************************************************************************/
 -- not sure this is a good idea.

/******************************************************************************
 * meta.field_id
 *****************************************************************************/
 -- not sure this is a good idea.

/******************************************************************************
 * meta.function_definition
 *
 * A view that contains the function_id and it's definition statement unparsed
 * and without any kind of metadata -- Built because meta.function was having
 * some problems, namely that argument names were not present, and are required
 * to recreate the function on an INSERT.  meta.function needs an entire
 * rewrite and potentially rethink, and ramifications on
 * endpoint.rows_select_function would be far-reaching and likely highly
 * disruptive.  Long term, function handling in both meta and endpoint need a
 * complete rewrite.  However, for bundle IO on meta.function rows, this might
 * actually be the simplest solution anyway.
 *****************************************************************************/

create or replace view meta.function_definition as
select
    meta.function_id( pronamespace::pg_catalog.regnamespace::text, proname::text, regexp_split_to_array(pg_catalog.pg_get_function_arguments(p.oid),', ')) as id,
    pg_catalog.pg_get_functiondef_no_searchpath(p.oid) as definition
from pg_catalog.pg_proc p
where prokind != 'a'; -- why??  otherwise I get "ERROR:  "sum" is an aggregate function"


create function meta.stmt_function_definition_create(definition text) returns text as $$
    select definition;
$$ language sql;


create function meta.stmt_function_definition_drop(function_id meta.function_id) returns text as $$
    select 'drop function ' || quote_ident((function_id::meta.schema_id).name) || '.' || quote_ident(function_id.name) || '(' ||
               array_to_string(function_id.parameters, ',') ||
           ');';
$$ language sql;


create function meta.function_definition_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['definition']);

        execute meta.stmt_function_definition_create(NEW.definition);

        return NEW;
    end;
$$ language plpgsql;


create function meta.function_definition_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['definition']);

        execute meta.stmt_function_definition_drop(OLD.id);
        execute meta.stmt_function_definition_create(NEW.definition);

        return NEW;
    end;
$$ language plpgsql;


create function meta.function_definition_delete() returns trigger as $$
    begin
        execute meta.stmt_function_definition_drop(OLD.id);
        return OLD;
    end;
$$ language plpgsql;



/******************************************************************************
 * meta.function
 *****************************************************************************/
create view meta.function as
    select id,
           schema_id,
           schema_name,
           name,
           parameters,
           definition,
           return_type,
           return_type_id,
           language,
           substring(pg_get_function_result((quote_ident(schema_name) || '.' || quote_ident(name) || '(' ||
               array_to_string(
                   coalesce(
                        nullif(
                           array_agg(coalesce(lower(nullif(p_in.parameter_mode, 'IN')) || ' ', '')
                                     || coalesce(nullif(nullif(p_in.data_type, 'ARRAY'), 'USER-DEFINED'), p_in.udt_schema || '.' || p_in.udt_name)
                                     order by p_in.ordinal_position),
                           array[null]
                       ),
                       array[]::text[]
                   ),
                   ', '
               )
           || ')')::regprocedure) from 1 for 6) = 'SETOF '

            -- FIXME: this circumvents information_schema and uses
            -- pg_catalog because pg_proc.proretset is not used in info_schema,
            -- so it doesn't have enough information to determine whether this
            -- record returns a setof.  not enough info?  and limit 1 is a
            -- hack.  this whole function needs a rewrite, so working around
            -- it for now.
               or (select proretset = 't' from pg_proc join pg_namespace on pg_proc.pronamespace = pg_namespace.oid where proname = q.name and nspname = q.schema_name limit 1)
           as returns_set

    from (
        select meta.function_id(
                r.routine_schema::text,
                r.routine_name::text,
                coalesce(
                    nullif(
                        array_agg( -- Array of types of the 'IN' parameters to this function
                            coalesce( nullif( nullif(p.data_type, 'ARRAY'), 'USER-DEFINED'), p.udt_schema || '.' || p.udt_name)
                            order by p.ordinal_position),
                        array[null]
                    ),
                    array[]::text[]
                )
            ) as id,
            meta.schema_id(r.routine_schema) as schema_id,
            r.routine_schema as schema_name,
            r.routine_name as name,
            r.specific_catalog,
            r.specific_schema,
            r.specific_name,
            coalesce(
                nullif(
                    array_agg( -- Array of types of the 'IN' parameters to this function
                        coalesce( nullif( nullif(p.data_type, 'ARRAY'), 'USER-DEFINED'), p.udt_schema || '.' || p.udt_name)
                        order by p.ordinal_position),
                    array[null]
                ),
                array[]::text[]
            ) as parameters,
            r.routine_definition::text as definition,
            coalesce(nullif(r.data_type, 'USER-DEFINED'), r.type_udt_schema || '.' || r.type_udt_name) as return_type,
            meta.type_id(r.type_udt_schema, r.type_udt_name) as return_type_id,
            lower(r.external_language)::information_schema.character_data::text as language

        from information_schema.routines r

            left join information_schema.parameters p
                on p.specific_catalog = r.specific_catalog and
                    p.specific_schema = r.specific_schema and
                    p.specific_name = r.specific_name 
   
        where r.routine_type = 'FUNCTION' and
            r.routine_name not in ('pg_identify_object', 'pg_sequence_parameters') and
            p.ordinal_position > 0 and
            p.parameter_mode like 'IN%' -- Includes IN and INOUT

        group by r.routine_catalog,
            r.routine_schema,
            r.routine_name,
            r.routine_definition,
            r.data_type,
            r.type_udt_schema,
            r.type_udt_name,
            r.external_language,
            r.specific_catalog,
            r.specific_schema,
            r.specific_name,
            p.specific_catalog,
            p.specific_schema,
            p.specific_name
    ) q

        left join information_schema.parameters p_in
            on p_in.specific_catalog = q.specific_catalog and
                p_in.specific_schema = q.specific_schema and
                p_in.specific_name = q.specific_name
         where
                p_in.ordinal_position > 0 and
                p_in.parameter_mode = 'IN'

    group by id,
        schema_id,
        schema_name,
        name,
        parameters,
        definition,
        return_type,
        return_type_id,
        language;



create view meta.function_parameter as
    select q.schema_id,
        q.schema_name,
        q.function_id,
        q.function_name,
        par.parameter_name as name,
        meta.type_id(par.udt_schema, par.udt_name) as type_id,
        quote_ident(par.udt_schema) || '.' || quote_ident(par.udt_name) as type_name,
        par.parameter_mode::text as "mode",
        par.ordinal_position::integer as position,
        par.parameter_default::text as "default"

    from (
        select meta.function_id(
                r.routine_schema::text,
                r.routine_name::text,
                coalesce(
                    nullif(
                array_agg( -- Array of types of the 'IN' parameters to this function
                    coalesce( nullif( nullif(p.data_type, 'ARRAY'), 'USER-DEFINED'), p.udt_schema || '.' || p.udt_name)
                    order by p.ordinal_position),
                array[null]
                    ),
                    array[]::text[]
                )
            ) as function_id,
            meta.schema_id(r.routine_schema) as schema_id,
            r.routine_schema as schema_name,
            r.routine_name as function_name,
            r.specific_catalog,
            r.specific_schema,
            r.specific_name

        from information_schema.routines r

            left join information_schema.parameters p
                on p.specific_catalog = r.specific_catalog and
                    p.specific_schema = r.specific_schema and
                    p.specific_name = r.specific_name

        where r.routine_type = 'FUNCTION' and
            r.routine_name not in ('pg_identify_object', 'pg_sequence_parameters') and
            p.parameter_mode like 'IN%' -- Includes IN and INOUT

        group by r.routine_catalog,
            r.routine_schema,
            r.routine_name,
            r.routine_definition,
            r.data_type,
            r.type_udt_schema,
            r.type_udt_name,
            r.external_language,
            r.specific_catalog,
            r.specific_schema,
            r.specific_name,
            p.specific_catalog,
            p.specific_schema,
            p.specific_name
    ) q
        join information_schema.parameters par
            on par.specific_catalog = q.specific_catalog and
                par.specific_schema = q.specific_schema and
                par.specific_name = q.specific_name;


create function meta.stmt_function_create(schema_name text, function_name text, parameters text[], return_type text, definition text, language text) returns text as $$
    select 'create function ' || quote_ident(schema_name) || '.' || quote_ident(function_name) || '(' ||
            array_to_string(parameters, ',') || ') returns ' || return_type || ' as $body$' || definition || '$body$
            language ' || quote_ident(language) || ';';
$$ language sql;


create function meta.stmt_function_drop(schema_name text, function_name text, parameters text[]) returns text as $$
    select 'drop function ' || quote_ident(schema_name) || '.' || quote_ident(function_name) || '(' ||
               array_to_string(parameters, ',') ||
           ');';
$$ language sql;


create function meta.function_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'parameters', 'return_type', 'definition', 'language']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        execute meta.stmt_function_create(coalesce(NEW.schema_name, (NEW.schema_id).name), NEW.name, NEW.parameters, NEW.return_type, NEW.definition, NEW.language);

        return NEW;
    end;
$$ language plpgsql;


create function meta.function_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'parameters', 'return_type', 'definition', 'language']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        execute meta.stmt_function_drop(OLD.schema_name, OLD.name, OLD.parameters);
        execute meta.stmt_function_create(coalesce(NEW.schema_name, (NEW.schema_id).name), NEW.name, NEW.parameters, NEW.return_type, NEW.definition, NEW.language);

        return NEW;
    end;
$$ language plpgsql;


create function meta.function_delete() returns trigger as $$
    begin
        execute meta.stmt_function_drop(OLD.schema_name, OLD.name, OLD.parameters);
        return OLD;
    end;
$$ language plpgsql;




/******************************************************************************
 * meta.type_definition
 *****************************************************************************/
create view meta.type_definition as
select
    meta.type_id(typnamespace::regnamespace::text, typname::text) as id,
    pg_catalog.get_typedef(t.oid) as definition,
    t.typtype as "type"
from pg_catalog.pg_type t
where t.typtype = 'c'
    and meta.type_id(typnamespace::regnamespace::text, typname::text) not in (
        select id from meta.table
        union
        select id from meta.view
    );

create function meta.stmt_type_definition_create(definition text) returns text as $$
    select definition;
$$ language sql;


create function meta.stmt_type_definition_drop(type_id meta.type_id) returns text as $$
    select 'drop type ' ||
        quote_ident((type_id::meta.schema_id).name) || '.' ||
        quote_ident(type_id.name) || ';';
$$ language sql;


create function meta.type_definition_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['definition']);

        execute meta.stmt_type_definition_create(NEW.definition);

        return NEW;
    end;
$$ language plpgsql;


create function meta.type_definition_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['definition']);

        execute meta.stmt_type_definition_drop(OLD.id);
        execute meta.stmt_type_definition_create(NEW.definition);

        return NEW;
    end;
$$ language plpgsql;


create function meta.type_definition_delete() returns trigger as $$
    begin
        execute meta.stmt_type_definition_drop(OLD.id);
        return OLD;
    end;
$$ language plpgsql;




/******************************************************************************
 * meta.trigger
 *****************************************************************************/
create view meta.trigger as
    select row(row(row(t_pgn.nspname), pgc.relname), pg_trigger.tgname)::meta.trigger_id as id,
           t.id as relation_id,
           t_pgn.nspname::text as schema_name,
           pgc.relname::text as relation_name,
           pg_trigger.tgname::text as name,
           f.id as function_id,
           case when (tgtype >> 1 & 1)::bool then 'before'
                when (tgtype >> 6 & 1)::bool then 'before'
                else 'after'
           end as "when",
           (tgtype >> 2 & 1)::bool as "insert",
           (tgtype >> 3 & 1)::bool as "delete",
           (tgtype >> 4 & 1)::bool as "update",
           (tgtype >> 5 & 1)::bool as "truncate",
           case when (tgtype & 1)::bool then 'row'
                else 'statement'
           end as level

    from pg_trigger

    inner join pg_class pgc
            on pgc.oid = tgrelid

    inner join pg_namespace t_pgn
            on t_pgn.oid = pgc.relnamespace

    inner join meta.schema t_s
            on t_s.name = t_pgn.nspname

    inner join meta.table t
            on t.schema_id = t_s.id and
               t.name = pgc.relname

    inner join pg_proc pgp
            on pgp.oid = tgfoid

    inner join pg_namespace f_pgn
            on f_pgn.oid = pgp.pronamespace

    inner join meta.schema f_s
            on f_s.name = f_pgn.nspname

    inner join meta.function f
            on f.schema_id = f_s.id and
               f.name = pgp.proname;


create function meta.stmt_trigger_create(schema_name text, relation_name text, trigger_name text, function_schema_name text, function_name text, "when" text, "insert" boolean, "update" boolean, "delete" boolean, "truncate" boolean, "level" text) returns text as $$
    select 'create trigger ' || quote_ident(trigger_name) || ' ' || "when" || ' ' ||
           array_to_string(
               array[]::text[]
               || case "insert" when true then 'insert'
                                    else null
                  end
               || case "update" when true then 'update'
                                    else null
                  end
               || case "delete" when true then 'delete'
                                    else null
                  end
               || case "truncate" when true then 'truncate'
                                      else null
                  end,
            ' or ') ||
            ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
            ' for each ' || "level" || ' execute procedure ' ||
            quote_ident(function_schema_name) || '.' || quote_ident(function_name) || '()';
$$ language sql;


create function meta.stmt_trigger_drop(schema_name text, relation_name text, trigger_name text) returns text as $$
    select 'drop trigger ' || quote_ident(trigger_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name);
$$ language sql;


create function meta.trigger_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'when', 'level']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'relation_name']);

        execute meta.stmt_trigger_create(
                    coalesce(NEW.schema_name, ((NEW.relation_id).schema_id).name),
                    coalesce(NEW.relation_name, (NEW.relation_id).name),
                    NEW.name,
                    ((NEW.function_id).schema_id).name,
                    (NEW.function_id).name,
                    NEW."when", NEW."insert", NEW."update", NEW."delete", NEW."truncate", NEW."level"
                );

        return NEW;
    end;
$$ language plpgsql;


create function meta.trigger_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'when', 'level']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'relation_name']);

        execute meta.stmt_trigger_drop(OLD.schema_name, OLD.relation_name, OLD.name);
        execute meta.stmt_trigger_create(
                    coalesce(nullif(NEW.schema_name, OLD.schema_name), ((NEW.relation_id).schema_id).name),
                    coalesce(nullif(NEW.relation_name, OLD.relation_name), (NEW.relation_id).name),
                    NEW.name,
                    ((NEW.function_id).schema_id).name,
                    (NEW.function_id).name,
                    NEW."when", NEW."insert", NEW."update", NEW."delete", NEW."truncate", NEW."level"
                );

        return NEW;
    end;
$$ language plpgsql;


create function meta.trigger_delete() returns trigger as $$
    begin
        execute meta.stmt_trigger_drop(OLD.schema_name, OLD.relation_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.role
 *****************************************************************************/
create view meta.role as
   select row(pgr.rolname)::meta.role_id as id,
          pgr.rolname::text  as name,
          pgr.rolsuper       as superuser,
          pgr.rolinherit     as inherit,
          pgr.rolcreaterole  as create_role,
          pgr.rolcreatedb    as create_db,
          pgr.rolcanlogin    as can_login,
          pgr.rolreplication as replication,
          pgr.rolconnlimit   as connection_limit,
          '********'::text   as password,
          pgr.rolvaliduntil  as valid_until
   from pg_roles pgr
   inner join pg_authid pga
           on pgr.oid = pga.oid
    union
   select '0'::oid::regrole::text::meta.role_id as id,
    'PUBLIC' as name,
    null, null, null, null, null, null, null, null, null;


create function meta.stmt_role_create(role_name text, superuser boolean, inherit boolean, create_role boolean, create_db boolean, can_login boolean, replication boolean, connection_limit integer, password text, valid_until timestamp with time zone) returns text as $$
    select  'create role ' || quote_ident(role_name) ||
            case when superuser then ' with superuser '
                                else ' with nosuperuser '
            end ||
            case when inherit then ' inherit '
                              else ' noinherit '
            end ||
            case when create_role then ' createrole '
                                  else ' nocreaterole '
            end ||
            case when create_db then ' createdb '
                                else ' nocreatedb '
            end ||
            case when can_login then ' login '
                                else ' nologin '
            end ||
            case when replication then ' replication '
                                  else ' noreplication '
            end ||
            coalesce(' connection limit ' || connection_limit, '') || -- can't take quoted literal
            coalesce(' password ' || quote_literal(password), '') ||
            coalesce(' valid until ' || quote_literal(valid_until), '');
$$ language sql;


create function meta.stmt_role_rename(role_name text, new_role_name text) returns text as $$
    select 'alter role ' || quote_ident(role_name) || ' rename to ' || quote_ident(new_role_name);
$$ language sql;


create function meta.stmt_role_alter(role_name text, superuser boolean, inherit boolean, create_role boolean, create_db boolean, can_login boolean, replication boolean, connection_limit integer, password text, valid_until timestamp with time zone) returns text as $$
    select  'alter role ' || quote_ident(role_name) ||
            case when superuser then ' with superuser '
                                else ' with nosuperuser '
            end ||
            case when inherit then ' inherit '
                              else ' noinherit '
            end ||
            case when create_role then ' createrole '
                                  else ' nocreaterole '
            end ||
            case when create_db then ' createdb '
                                else ' nocreatedb '
            end ||
            case when can_login then ' login '
                                else ' nologin '
            end ||
            case when replication then ' replication '
                                  else ' noreplication '
            end ||
            case when connection_limit is not null then ' connection limit ' || connection_limit -- can't take quoted literal
                                                   else ''
            end ||
            case when password is not null and password <> '********' then ' password ' || quote_literal(password)
                                           else ''
            end ||
            case when valid_until is not null then ' valid until ' || quote_literal(valid_until)
                                              else ''
            end;
$$ language sql;


create function meta.stmt_role_reset(role_name text, config_param text) returns text as $$
    select 'alter role ' || quote_ident(role_name) || ' reset ' || config_param;
$$ language sql;


create function meta.stmt_role_drop(role_name text) returns text as $$
    select 'drop role ' || quote_ident(role_name);
$$ language sql;


create function meta.role_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        execute meta.stmt_role_create(NEW.name, NEW.superuser, NEW.inherit, NEW.create_role, NEW.create_db, NEW.can_login, NEW.replication, NEW.connection_limit, NEW.password, NEW.valid_until);
        return NEW;
    end;
$$ language plpgsql;


create function meta.role_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        if OLD.name != NEW.name then
            execute meta.stmt_role_rename(OLD.name, NEW.name);
        end if;

        execute meta.stmt_role_alter(NEW.name, NEW.superuser, NEW.inherit, NEW.create_role, NEW.create_db, NEW.can_login, NEW.replication, NEW.connection_limit, NEW.password, NEW.valid_until);

        if OLD.connection_limit is not null and NEW.connection_limit is null then
            perform meta.stmt_role_reset(NEW.name, 'connection limit');
        end if;

        if OLD.password is not null and NEW.password is null then
            perform meta.stmt_role_reset(NEW.name, 'password');
        end if;

        if OLD.valid_until is not null and NEW.valid_until is null then
            perform meta.stmt_role_reset(NEW.name, 'valid until');
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.role_delete() returns trigger as $$
    begin
        execute meta.stmt_role_drop(OLD.name);
        return OLD;
    end;
$$ language plpgsql;


create function meta.current_role_id() returns meta.role_id as $$
    select id from meta.role where name=current_user;
$$ language sql;


/******************************************************************************
 * meta.role_inheritance
 *****************************************************************************/
create view meta.role_inheritance as
select
    r.rolname::text || '<-->' || r2.rolname::text as id,
    r.rolname::text::meta.role_id as role_id,
    r.rolname::text as role_name,
    r2.rolname::text::meta.role_id as member_role_id,
    r2.rolname::text as member_role_name
from pg_auth_members m
    join pg_roles r on r.oid = m.roleid
    join pg_roles r2 on r2.oid = m.member;


create function meta.stmt_role_inheritance_create(role_name text, member_role_name text) returns text as $$
    select  'grant ' || quote_ident(role_name) || ' to ' || quote_ident(member_role_name);
$$ language sql;


create function meta.stmt_role_inheritance_drop(role_name text, member_role_name text) returns text as $$
    select 'revoke ' || quote_ident(role_name) || ' from ' || quote_ident(member_role_name);
$$ language sql;


create function meta.role_inheritance_insert() returns trigger as $$
    begin

        perform meta.require_one(public.hstore(NEW), array['role_name', 'role_id']);
        perform meta.require_one(public.hstore(NEW), array['member_role_name', 'member_role_id']);

        execute meta.stmt_role_inheritance_create(coalesce(NEW.role_name, (NEW.role_id).name), coalesce(NEW.member_role_name, (NEW.member_role_id).name));

        return NEW;
    end;
$$ language plpgsql;


create function meta.role_inheritance_update() returns trigger as $$
    begin
        perform meta.require_one(public.hstore(NEW), array['role_id', 'role_name']);
        perform meta.require_one(public.hstore(NEW), array['member_role_id', 'member_role_name']);

        execute meta.stmt_role_inheritance_drop((OLD.role_id).name, (OLD.member_role_id).name);
        execute meta.stmt_role_inheritance_create(coalesce(NEW.role_name, (NEW.role_id).name), coalesce(NEW.member_role_name, (NEW.member_role_id).name));

        return NEW;
    end;
$$ language plpgsql;


create function meta.role_inheritance_delete() returns trigger as $$
    begin
        execute meta.stmt_role_inheritance_drop((OLD.role_id).name, (OLD.member_role_id).name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.table_privilege
 *****************************************************************************/
create or replace view meta.table_privilege as
select meta.table_privilege_id(schema_name, table_name, (role_id).name, type) as id,
    meta.relation_id(schema_name, table_name) as table_id,
    schema_name::text,
    table_name::text,
    role_id,
    (role_id).name as role_name,
    type::text,
    is_grantable::boolean,
    with_hierarchy::boolean
from (
    select
        case grantee
            when 'PUBLIC' then
                '-'::text::meta.role_id
            else
                grantee::text::meta.role_id
        end as role_id,
        table_schema as schema_name,
        table_name,
        privilege_type as type,
        is_grantable,
        with_hierarchy
    from information_schema.role_table_grants
    where table_catalog = current_database()
) a;


create function meta.stmt_table_privilege_create(schema_name text, table_name text, role_name text, type text) returns text as $$
    -- TODO: create privilege_type so that "type" can be escaped here
    select 'grant ' || type || ' on ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' to ' || quote_ident(role_name);
$$ language sql;


create function meta.stmt_table_privilege_drop(schema_name text, table_name text, role_name text, type text) returns text as $$
    -- TODO: create privilege_type so that "type" can be escaped here
    select 'revoke ' || type || ' on ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' from ' || quote_ident(role_name);
$$ language sql;


create function meta.table_privilege_insert() returns trigger as $$
    begin
        perform meta.require_one(public.hstore(NEW), array['role_id', 'role_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);
        perform meta.require_all(public.hstore(NEW), array['type']);

        execute meta.stmt_table_privilege_create(
        coalesce(NEW.schema_name, ((NEW.table_id).schema_id).name),
        coalesce(NEW.table_name, (NEW.table_id).name),
        coalesce(NEW.role_name, (NEW.role_id).name),
        NEW.type);

        return NEW;
    end;
$$ language plpgsql;


create function meta.table_privilege_update() returns trigger as $$
    begin
        perform meta.require_one(public.hstore(NEW), array['role_id', 'role_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);
        perform meta.require_all(public.hstore(NEW), array['type']);

        execute meta.stmt_table_privilege_drop(OLD.schema_name, OLD.table_name, OLD.role_name, OLD.type);

        execute meta.stmt_table_privilege_create(
        coalesce(NEW.schema_name, ((NEW.table_id).schema_id).name),
        coalesce(NEW.table_name, (NEW.table_id).name),
        coalesce(NEW.role_name, (NEW.role_id).name),
        NEW.type);

        return NEW;
    end;
$$ language plpgsql;


create function meta.table_privilege_delete() returns trigger as $$
    begin
        execute meta.stmt_table_privilege_drop(OLD.schema_name, OLD.table_name, OLD.role_name, OLD.type);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.policy
 *****************************************************************************/
create view meta.policy as
select meta.policy_id(meta.relation_id(n.nspname, c.relname), p.polname) as id,
    p.polname::text as name,
    meta.relation_id(n.nspname, c.relname) as relation_id,
    c.relname::text as relation_name,
    n.nspname::text as schema_name,
    p.polcmd::char::meta.siuda as command,
    pg_get_expr(p.polqual, p.polrelid, True) as using,
    pg_get_expr(p.polwithcheck, p.polrelid, True) as check
from pg_policy p
    join pg_class c on c.oid = p.polrelid
    join pg_namespace n on n.oid = c.relnamespace;


create function meta.stmt_policy_create(schema_name text, relation_name text, policy_name text, command meta.siuda, "using" text, "check" text) returns text as $$
    select  'create policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
            case when command is not null then ' for ' || command::text
                      else ''
            end ||
            case when "using" is not null then ' using (' || "using" || ')'
                    else ''
            end ||
            case when "check" is not null then ' with check (' || "check" || ')'
                    else ''
            end;
$$ language sql;


create function meta.stmt_policy_rename(schema_name text, relation_name text, policy_name text, new_policy_name text) returns text as $$
    select 'alter policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) || ' rename to ' || quote_ident(new_policy_name);
$$ language sql;


create function meta.stmt_policy_alter(schema_name text, relation_name text, policy_name text, "using" text, "check" text) returns text as $$
    select  'alter policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
            case when "using" is not null then ' using (' || "using" || ')'
                    else ''
            end ||
            case when "check" is not null then ' with check (' || "check" || ')'
                        else ''
            end;
$$ language sql;


create function meta.stmt_policy_drop(schema_name text, relation_name text, policy_name text) returns text as $$
    select 'drop policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name);
$$ language sql;


create function meta.policy_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['relation_id', 'relation_name']);

        execute meta.stmt_policy_create(coalesce(NEW.schema_name, ((NEW.relation_id).schema_id).name), coalesce(NEW.relation_name, (NEW.relation_id).name), NEW.name, NEW.command, NEW."using", NEW."check");

        return NEW;
    end;
$$ language plpgsql;


create function meta.policy_update() returns trigger as $$
    declare
    schema_name text;
    relation_name text;
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

    -- could support moving policy to new relation, but is that useful?
        if NEW.relation_id is not null and OLD.relation_id != NEW.relation_id or
           NEW.schema_name is not null and OLD.schema_name != NEW.schema_name or
           NEW.relation_name is not null and OLD.relation_name != NEW.relation_name then

            raise exception 'Moving a policy to another table is not yet supported.';
        end if;

        if OLD.command != NEW.command then
            raise exception 'Postgres does not allow altering the type of command';
        end if;

        schema_name := OLD.schema_name;
        relation_name := OLD.relation_name;

        if OLD.name != NEW.name then
            execute meta.stmt_policy_rename(schema_name, relation_name, OLD.name, NEW.name);
        end if;

        execute meta.stmt_policy_alter(schema_name, relation_name, NEW.name, NEW."using", NEW."check");

        return NEW;
    end;
$$ language plpgsql;


create function meta.policy_delete() returns trigger as $$
    begin
        execute meta.stmt_policy_drop(OLD.schema_name, OLD.relation_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.policy_role
 *****************************************************************************/
create view meta.policy_role as
select
    meta.policy_id(relation_id, policy_name)::text || '<-->' || role_id::text as id,
    meta.policy_id(relation_id, policy_name) as policy_id,
    policy_name::text,
    relation_id,
    (relation_id).name as relation_name,
    ((relation_id).schema_id).name as schema_name,
    role_id,
    (role_id).name as role_name
from (
    select
        p.polname as policy_name,
        meta.relation_id(n.nspname, c.relname) as relation_id,
        unnest(p.polroles::regrole[]::text[]::meta.role_id[]) as role_id
    from pg_policy p
        join pg_class c on c.oid = p.polrelid
        join pg_namespace n on n.oid = c.relnamespace
) a;


create function meta.stmt_policy_role_create(schema_name text, relation_name text, policy_name text, role_name text) returns text as $$
    select  'alter policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
        ' to ' ||
        ( select array_to_string(
            array_append(
                array_remove(
                    array(
                        select distinct(unnest(polroles::regrole[]::text[]))
                                                from pg_policy p
                                                    join pg_class c on c.oid = p.polrelid
                                                    join pg_namespace n on n.oid = c.relnamespace
                        where polname = policy_name
                                                    and meta.relation_id(n.nspname, c.relname) = meta.relation_id(schema_name, relation_name)
                    ),
                '-'), -- Remove public from list of roles
            quote_ident(role_name)),
         ', '));
$$ language sql;


create function meta.stmt_policy_role_drop(schema_name text, relation_name text, policy_name text, role_name text) returns text as $$
declare
    roles text;
begin
    select array_to_string(
        array_remove(
            array_remove(
                array(
                    select distinct(unnest(polroles::regrole[]::text[]))
                                        from pg_policy p
                                            join pg_class c on c.oid = p.polrelid
                                            join pg_namespace n on n.oid = c.relnamespace
                    where polname = policy_name
                                            and meta.relation_id(n.nspname, c.relname) = meta.relation_id(schema_name, relation_name)
                ),
            '-'), -- Remove public from list of roles
        role_name),
     ', ') into roles;

    if roles = '' then
        return  'alter policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) || ' to public';
    else
        return  'alter policy ' || quote_ident(policy_name) || ' on ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) || ' to ' || roles;
    end if;
end;
$$ language plpgsql;


create function meta.policy_role_insert() returns trigger as $$
    begin

        perform meta.require_one(public.hstore(NEW), array['policy_name', 'policy_id']);
        perform meta.require_one(public.hstore(NEW), array['role_name', 'role_id']);
        perform meta.require_one(public.hstore(NEW), array['policy_id', 'relation_id', 'relation_name']);
        perform meta.require_one(public.hstore(NEW), array['policy_id', 'relation_id', 'schema_name']);

        execute meta.stmt_policy_role_create(
        coalesce(NEW.schema_name, ((NEW.relation_id).schema_id).name, (((NEW.policy_id).relation_id).schema_id).name),
        coalesce(NEW.relation_name, (NEW.relation_id).name, ((NEW.policy_id).relation_id).name),
        coalesce(NEW.policy_name, (NEW.policy_id).name),
        coalesce(NEW.role_name, (NEW.role_id).name));

        return NEW;
    end;
$$ language plpgsql;


create function meta.policy_role_update() returns trigger as $$
    begin
        perform meta.require_one(public.hstore(NEW), array['policy_name', 'policy_id']);
        perform meta.require_one(public.hstore(NEW), array['role_name', 'role_id']);
        perform meta.require_one(public.hstore(NEW), array['policy_id', 'relation_id', 'relation_name']);
        perform meta.require_one(public.hstore(NEW), array['policy_id', 'relation_id', 'schema_name']);

    -- delete old policy_role
        execute meta.stmt_policy_role_drop((((OLD.policy_id).relation_id).schema_id).name, ((OLD.policy_id).relation_id).name, (OLD.policy_id).name, (OLD.role_id).name);

    -- create new policy_role
        execute meta.stmt_policy_role_create(
        coalesce(NEW.schema_name, ((NEW.relation_id).schema_id).name, (((NEW.policy_id).relation_id).schema_id).name),
        coalesce(NEW.relation_name, (NEW.relation_id).name, ((NEW.policy_id).relation_id).name),
        coalesce(NEW.policy_name, (NEW.policy_id).name),
        coalesce(NEW.role_name, (NEW.role_id).name));

        return NEW;

    end;
$$ language plpgsql;


create function meta.policy_role_delete() returns trigger as $$
    begin
        execute meta.stmt_policy_role_drop((((OLD.policy_id).relation_id).schema_id).name, ((OLD.policy_id).relation_id).name, (OLD.policy_id).name, (OLD.role_id).name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.connection
 *****************************************************************************/
create view meta.connection as
   select row(psa.pid, psa.backend_start)::meta.connection_id as id,
          row(psa.usename::text)::meta.role_id as role_id,
          psa.datname::text as database_name,
          psa.pid as unix_pid,
          psa.application_name,
          psa.client_addr as client_ip,
          psa.client_hostname as client_hostname,
          psa.client_port as client_port,
          psa.backend_start as connection_start,
          psa.xact_start as transaction_start,
          psa.query as last_query,
          psa.query_start as query_start,
          psa.state as state,
          psa.state_change as last_state_change,
          psa.wait_event as wait_event,
          psa.wait_event_type as wait_event_type
   from pg_stat_activity psa;


create function meta.stmt_connection_delete(unix_pid integer) returns text as $$
    select 'select pg_terminate_backend( ' || unix_pid || ')'
$$ language sql;


create function meta.connection_delete() returns trigger as $$
    begin
        execute meta.stmt_connection_delete(OLD.unix_pid);
        return OLD;
    end;
$$ language plpgsql;

create function meta.current_connection_id() returns meta.connection_id as $$
    select id from meta.connection where unix_pid=pg_backend_pid();
$$ language sql;

/******************************************************************************
 * meta.constraint_unique
 *****************************************************************************/
create view meta.constraint_unique as
    select row(row(row(tc.table_schema), tc.table_name), tc.constraint_name)::meta.constraint_id as id,
           row(row(tc.table_schema), tc.table_name)::meta.relation_id as table_id,
           tc.table_schema::text as schema_name,
           tc.table_name::text as table_name,
           tc.constraint_name::text as name,
           array_agg(row(row(row(ccu.table_schema), ccu.table_name), ccu.column_name)::meta.column_id) as column_ids,
           array_agg(ccu.column_name::text) as column_names

    from information_schema.table_constraints tc

    inner join information_schema.constraint_column_usage ccu
            on ccu.constraint_catalog = tc.constraint_catalog and
               ccu.constraint_schema = tc.constraint_schema and
               ccu.constraint_name = tc.constraint_name

    where constraint_type = 'UNIQUE'

    group by tc.table_schema, tc.table_name, tc.constraint_name;


create function meta.constraint_unique_create(schema_name text, table_name text, name text, column_names text[]) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' add constraint ' || quote_ident(name) ||
           ' unique(' || array_to_string(column_names, ', ') || ')';
$$ language sql;


create function meta.constraint_unique_drop(schema_name text, table_name text, "name" text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' drop constraint ' || quote_ident(name);
$$ language sql;


create function meta.constraint_unique_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);
        perform meta.require_one(public.hstore(NEW), array['column_ids', 'column_names']);

        if array_length(NEW.column_names, 1) = 0 or array_length(NEW.column_ids, 1) = 0 then
            raise exception 'Unique constraints must have at least one column.';
        end if;

        execute meta.constraint_unique_create(
                    coalesce(NEW.schema_name, ((NEW.table_id).schema_id).name),
                    coalesce(NEW.table_name, (NEW.table_id).name),
                    NEW.name,
                    coalesce(NEW.column_names, (
                        select array_agg((column_id).name) as column_name
                        from (
                            select unnest(NEW.column_ids) as column_id
                        ) c
                    ))
                );

        return NEW;
    end;
$$ language plpgsql;


create function meta.constraint_unique_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);
        perform meta.require_one(public.hstore(NEW), array['column_ids', 'column_names']);

        if array_length(NEW.column_names, 1) = 0 or array_length(NEW.column_ids, 1) = 0 then
            raise exception 'Unique constraints must have at least one column.';
        end if;

        execute meta.constraint_unique_drop(OLD.schema_name, OLD.table_name, OLD.name);
        execute meta.constraint_unique_create(
                    coalesce(nullif(NEW.schema_name, OLD.schema_name), ((NEW.table_id).schema_id).name),
                    coalesce(nullif(NEW.table_name, OLD.table_name), (NEW.table_id).name),
                    NEW.name,
                    coalesce(nullif(NEW.column_names, OLD.column_names), (
                        select array_agg((column_id).name) as column_name
                        from (
                            select unnest(NEW.column_ids) as column_id
                        ) c
                    ))
                );

        return NEW;
    end;
$$ language plpgsql;


create function meta.constraint_unique_delete() returns trigger as $$
    begin
        execute meta.constraint_unique_drop(OLD.schema_name, OLD.table_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.constraint_check
 *****************************************************************************/
create view meta.constraint_check as
    select row(row(row(tc.table_schema), tc.table_name), tc.constraint_name)::meta.constraint_id as id,
           row(row(tc.table_schema), tc.table_name)::meta.relation_id as table_id,
           tc.table_schema::text as schema_name,
           tc.table_name::text as table_name,
           tc.constraint_name::text as name,
           cc.check_clause::text

    from information_schema.table_constraints tc

    inner join information_schema.check_constraints cc
            on cc.constraint_catalog = tc.constraint_catalog and
               cc.constraint_schema = tc.constraint_schema and
               cc.constraint_name = tc.constraint_name;


create function meta.constraint_check_create(schema_name text, table_name text, name text, check_clause text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' add constraint ' || quote_ident(name) ||
           ' check (' || check_clause || ')';
$$ language sql;


create function meta.constraint_check_drop(schema_name text, table_name text, "name" text) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' drop constraint ' || quote_ident(name);
$$ language sql;


create function meta.constraint_check_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'check_clause']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);

        execute meta.constraint_check_create(
                    coalesce(NEW.schema_name, ((NEW.table_id).schema_id).name),
                    coalesce(NEW.table_name, (NEW.table_id).name),
                    NEW.name, NEW.check_clause
                );

        return NEW;
    end;
$$ language plpgsql;


create function meta.constraint_check_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'check_clause']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['table_id', 'table_name']);

        execute meta.constraint_check_drop(OLD.schema_name, OLD.table_name, OLD.name);
        execute meta.constraint_check_create(
                    coalesce(nullif(NEW.schema_name, OLD.schema_name), ((NEW.table_id).schema_id).name),
                    coalesce(nullif(NEW.table_name, OLD.table_name), (NEW.table_id).name),
                    NEW.name, NEW.check_clause
                );

        return NEW;
    end;
$$ language plpgsql;


create function meta.constraint_check_delete() returns trigger as $$
    begin
        execute meta.constraint_check_drop(OLD.schema_name, OLD.table_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;


/******************************************************************************
 * meta.extension
 *****************************************************************************/
create view meta.extension as
    select meta.extension_id(ext.extname) as id,
           meta.schema_id(pgn.nspname) as schema_id,
           pgn.nspname::text as schema_name,
           ext.extname::text as name,
           ext.extversion as version

    from pg_catalog.pg_extension ext
    inner join pg_catalog.pg_namespace pgn
            on pgn.oid = ext.extnamespace;


create function meta.stmt_extension_create(
    schema_name text,
    name text,
    version text
) returns text as $$
    select 'create extension ' || quote_ident(name)
           || ' schema ' || quote_ident(schema_name)
           || coalesce(' version ' || version, '');
$$ language sql immutable;


create function meta.stmt_extension_set_schema(
    name text,
    new_schema_name text
) returns text as $$
    select 'alter extension ' || quote_ident(name)
           || ' set schema ' || quote_ident(new_schema_name);
$$ language sql immutable;


create function meta.stmt_extension_set_version(
    name text,
    version text
) returns text as $$
    select 'alter extension ' || quote_ident(name)
           || ' version ' || version;
$$ language sql;


create function meta.stmt_extension_drop(name text) returns text as $$
    select 'drop extension ' || quote_ident(name);
$$ language sql;


create function meta.extension_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        execute meta.stmt_extension_create(
            coalesce(NEW.schema_name, (NEW.schema_id).name),
            NEW.name,
            NEW.version
        );

        NEW.id := meta.extension_id(NEW.name);

        return NEW;
    end;
$$ language plpgsql;


create function meta.extension_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        if NEW.schema_id != OLD.schema_id or OLD.schema_name != NEW.schema_name then
            execute meta.stmt_extension_set_schema(OLD.name, coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name));
        end if;

        if NEW.name != OLD.name then
            raise exception 'Extensions cannot be renamed.';
        end if;

        if NEW.version != OLD.version then
            execute meta.stmt_extension_alter(NEW.name, NEW.version);
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.extension_delete() returns trigger as $$
    begin
        execute meta.stmt_extension_drop(OLD.name);
        return OLD;
    end;
$$ language plpgsql;

/******************************************************************************
 * meta.foreign_data_wrapper
 *****************************************************************************/
create view meta.foreign_data_wrapper as
    select id,
           name::text,
           handler_id,
           validator_id,
           string_agg((quote_ident(opt[1]) || '=>' || replace(array_to_string(opt[2:array_length(opt, 1)], '='), ',', '\,')), ',')::public.hstore as options

    from (
        select meta.foreign_data_wrapper_id(fdwname) as id,
               fdwname as name,
               h_f.id as handler_id,
               v_f.id as validator_id,
               string_to_array(unnest(coalesce(fdwoptions, array['']::text[])), '=') as opt

        from pg_catalog.pg_foreign_data_wrapper

        left join pg_proc p_h
               on p_h.oid = fdwhandler

        left join pg_namespace h_n
               on h_n.oid = p_h.pronamespace

        left join meta.function h_f
               on h_f.schema_name = h_n.nspname and
                  h_f.name = p_h.proname

        left join pg_proc p_v
               on p_v.oid = fdwvalidator

        left join pg_namespace v_n
               on v_n.oid = p_v.pronamespace

        left join meta.function v_f
               on v_f.schema_name = v_n.nspname and
                  v_f.name = p_v.proname
    ) q

    group by id,
             name,
             handler_id,
             validator_id;


create function meta.stmt_foreign_data_wrapper_create(
    name text,
    handler_id meta.function_id,
    validator_id meta.function_id,
    options public.hstore
) returns text as $$
    select 'create foreign data wrapper ' || quote_ident(name)
           || coalesce(' handler ' || quote_ident((handler_id).schema_id.name) || '.'  || quote_ident((handler_id).name), ' no handler ')
           || coalesce(' validator ' || quote_ident((validator_id).schema_id.name) || '.'  || quote_ident((validator_id).name), ' no validator ')
           || coalesce(' options (' || (
               select string_agg(key || ' ' || quote_literal(value), ',') from public.each(options)
           ) || ')', '');
$$ language sql immutable;


create function meta.stmt_foreign_data_wrapper_rename(
    name text,
    new_name text
) returns text as $$
    select 'alter foreign data wrapper ' || quote_ident(name) || ' rename to ' || quote_ident(new_name);
$$ language sql immutable;


create function meta.stmt_foreign_data_wrapper_alter(
    name text,
    handler_id meta.function_id,
    validator_id meta.function_id
) returns text as $$
    select 'alter foreign data wrapper ' || quote_ident(name)
           || coalesce(' handler ' || quote_ident((handler_id).schema_id.name) || '.'  || quote_ident((handler_id).name), ' no handler ')
           || coalesce(' validator ' || quote_ident((validator_id).schema_id.name) || '.'  || quote_ident((validator_id).name), ' no validator ');
$$ language sql immutable;


create function meta.stmt_foreign_data_wrapper_drop_options(
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    set local search_path=public,meta;
    select 'alter foreign data wrapper ' || quote_ident(name) || ' options (' || (
        select string_agg('drop ' || key, ',') from public.each(options - public.akeys(new_options)::public.hstore)
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_data_wrapper_set_options(
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter foreign data wrapper ' || quote_ident(name) || ' options (' || (
        select string_agg('set ' || key || ' ' || quote_literal(value), ',')
        from each(new_options) where options ? key
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_data_wrapper_add_options(
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter foreign data wrapper ' || quote_ident(name) || ' options (' || (
        select string_agg('add ' || key || ' ' || quote_literal(value), ',')
        from public.each(new_options - public.akeys(options))
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_data_wrapper_drop(name text) returns text as $$
    select 'drop foreign data wrapper ' || quote_ident(name);
$$ language sql;


create function meta.foreign_data_wrapper_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        execute meta.stmt_foreign_data_wrapper_create(
            NEW.name,
            NEW.handler_id,
            NEW.validator_id,
            NEW.options
        );

        NEW.id := meta.foreign_data_wrapper_id(NEW.name);

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_data_wrapper_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        if NEW.name != OLD.name then
            execute meta.stmt_foreign_data_wrapper_rename(OLD.name, NEW.name);
        end if;

        if NEW.options != OLD.options then
            execute meta.stmt_foreign_data_wrapper_drop_options(NEW.name, OLD.options, NEW.options);
            execute meta.stmt_foreign_data_wrapper_set_options(NEW.name, OLD.options, NEW.options);
            execute meta.stmt_foreign_data_wrapper_add_options(NEW.name, OLD.options, NEW.options);
        end if;

        execute meta.stmt_foreign_data_wrapper_alter(NEW.name, NEW.handler_id, NEW.validator_id);

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_data_wrapper_delete() returns trigger as $$
    begin
        execute meta.stmt_foreign_data_wrapper_drop(OLD.name);
        return OLD;
    end;
$$ language plpgsql;



/******************************************************************************
 * meta.foreign_server
 *****************************************************************************/
create view meta.foreign_server as
    select id,
           foreign_data_wrapper_id,
           name::text,
           "type",
           version,
           string_agg((quote_ident(opt[1]) || '=>' || replace(array_to_string(opt[2:array_length(opt, 1)], '='), ',', '\,')), ',')::public.hstore as options

    from (
        select row(srvname)::meta.foreign_server_id as id,
               row(fdwname)::meta.foreign_data_wrapper_id as foreign_data_wrapper_id,
               srvname as name,
               srvtype as "type",
               srvversion as version,
               string_to_array(unnest(coalesce(srvoptions, array['']::text[])), '=') as opt

        from pg_catalog.pg_foreign_server fs
        inner join pg_catalog.pg_foreign_data_wrapper fdw
                on fdw.oid = fs.srvfdw
    ) q

    group by id,
             foreign_data_wrapper_id,
             name,
             "type",
             version;


create function meta.stmt_foreign_server_create(
    foreign_data_wrapper_id meta.foreign_data_wrapper_id,
    name text,
    "type" text,
    version text,
    options public.hstore
) returns text as $$
    select 'create server ' || quote_ident(name)
           || coalesce(' type ' || quote_literal("type"), '')
           || coalesce(' version ' || quote_literal(version), '')
           || ' foreign data wrapper ' || quote_ident((foreign_data_wrapper_id).name)
           || coalesce(' options (' || (
               select string_agg(key || ' ' || quote_literal(value), ',') from public.each(options)
           ) || ')', '');
$$ language sql immutable;


create function meta.stmt_foreign_server_rename(
    name text,
    new_name text
) returns text as $$
    select 'alter server ' || quote_ident(name) || ' rename to ' || quote_ident(new_name);
$$ language sql immutable;


create function meta.stmt_foreign_server_set_version(
    name text,
    version text
) returns text as $$
    select 'alter server ' || quote_ident(name) || ' version ' || quote_literal(version);
$$ language sql immutable;


create function meta.stmt_foreign_server_drop_options(
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter server ' || quote_ident(name) || ' options (' || (
        select string_agg('drop ' || key, ',') from public.each(options - public.akeys(new_options))
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_server_set_options(
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter server ' || quote_ident(name) || ' options (' || (
        select string_agg('set ' || key || ' ' || quote_literal(value), ',')
        from public.each(new_options) where options ? key
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_server_add_options(
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter server ' || quote_ident(name) || ' options (' || (
        select string_agg('add ' || key || ' ' || quote_literal(value), ',')
        from public.each(new_options - public.akeys(options))
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_server_drop(name text) returns text as $$
    select 'drop server ' || quote_ident(name);
$$ language sql;


create function meta.foreign_server_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        execute meta.stmt_foreign_server_create(
            NEW.foreign_data_wrapper_id,
            NEW.name,
            NEW."type",
            NEW.version,
            NEW.options
        );

        NEW.id := meta.foreign_server_id(NEW.name);

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_server_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name']);

        if NEW.name != OLD.name then
            execute meta.stmt_foreign_server_rename(OLD.name, NEW.name);
        end if;

        if NEW.foreign_data_wrapper_id is distinct from OLD.foreign_data_wrapper_id then
            raise exception 'Server''s foreign data wrapper cannot be altered.';
        end if;

        if NEW.type is distinct from OLD.type then
            raise exception 'Server type cannot be altered.';
        end if;

        if NEW.version is distinct from OLD.version then
            execute meta.stmt_foreign_server_set_version(NEW.name, NEW.version);
        end if;

        if NEW.options is distinct from OLD.options then
            execute meta.stmt_foreign_server_drop_options(NEW.name, OLD.options, NEW.options);
            execute meta.stmt_foreign_server_set_options(NEW.name, OLD.options, NEW.options);
            execute meta.stmt_foreign_server_add_options(NEW.name, OLD.options, NEW.options);
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_server_delete() returns trigger as $$
    begin
        execute meta.stmt_foreign_server_drop(OLD.name);
        return OLD;
    end;
$$ language plpgsql;



/******************************************************************************
 * meta.foreign_table
 *****************************************************************************/
create view meta.foreign_table as
    select id,
           foreign_server_id,
           schema_id,
           schema_name::text,
           name::text,
           string_agg((quote_ident(opt[1]) || '=>' || replace(array_to_string(opt[2:array_length(opt, 1)], '='), ',', '\,')), ',')::public.hstore as options

    from (
        select meta.relation_id(pgn.nspname, pgc.relname) as id,
               meta.schema_id(pgn.nspname) as schema_id,
               meta.foreign_server_id(pfs.srvname) as foreign_server_id,
               pgn.nspname as schema_name,
               pgc.relname as name,
               string_to_array(unnest(coalesce(ftoptions, array['']::text[])), '=') as opt

        from pg_catalog.pg_foreign_table pft
        inner join pg_catalog.pg_class pgc
                on pgc.oid = pft.ftrelid
        inner join pg_catalog.pg_namespace pgn
                on pgn.oid = pgc.relnamespace
        inner join pg_catalog.pg_foreign_server pfs
                on pfs.oid = pft.ftserver
    ) q

    group by id,
             schema_id,
             foreign_server_id,
             schema_name,
             name;
/*
TODO: create function meta.foreign-table...
*/

create function meta.stmt_foreign_table_create(
    foreign_server_id meta.foreign_server_id,
    schema_name text,
    name text,
    options public.hstore
) returns text as $$
    select 'create foreign table ' || quote_ident(schema_name) || '.' || quote_ident(name) || '()'
           || ' server ' || quote_ident((foreign_server_id).name)
           || coalesce(' options (' || (
               select string_agg(key || ' ' || quote_literal(value), ',')
               from each(options)
           ) || ')', '');
$$ language sql;


create function meta.stmt_foreign_table_set_schema(
    schema_name text,
    name text,
    new_schema_name text
) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(name)
           || ' set schema ' || quote_ident(new_schema_name);
$$ language sql;


create function meta.stmt_foreign_table_drop_options(
    schema_name text,
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(name) || ' options (' || (
        select string_agg('drop ' || key, ',') from each(options - public.akeys(new_options))
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_table_set_options(
    schema_name text,
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(name) || ' options (' || (
        select string_agg('set ' || key || ' ' || quote_literal(value), ',')
        from each(new_options) where options ? key
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_table_add_options(
    schema_name text,
    name text,
    options public.hstore,
    new_options public.hstore
) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(name) || ' options (' || (
        select string_agg('add ' || key || ' ' || quote_literal(value), ',')
        from each(new_options - public.akeys(options))
    ) || ')';
$$ language sql;


create function meta.stmt_foreign_table_rename(
    schema_name text,
    name text,
    new_name text
) returns text as $$
    select 'alter table ' || quote_ident(schema_name) || '.' || quote_ident(name)
           || ' rename to ' || quote_ident(new_name);
$$ language sql;


create function meta.stmt_foreign_table_drop(schema_name text, name text) returns text as $$
    select 'drop foreign table ' || quote_ident(schema_name) || '.' || quote_ident(name);
$$ language sql;


create function meta.foreign_table_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['foreign_server_id', 'name']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        execute meta.stmt_foreign_table_create(
            NEW.foreign_server_id,
            coalesce(NEW.schema_name, (NEW.schema_id).name),
            NEW.name,
            NEW.options
        );

        NEW.id := meta.relation_id(coalesce(NEW.schema_name, (NEW.schema_id).name), NEW.name);

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_table_update() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['foreign_server_id', 'name']);
        perform meta.require_one(public.hstore(NEW), array['schema_id', 'schema_name']);

        if NEW.schema_id != OLD.schema_id or OLD.schema_name != NEW.schema_name then
            execute meta.stmt_foreign_table_set_schema(OLD.schema_name, OLD.name, coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name));
        end if;

        if NEW.foreign_server_id != OLD.foreign_server_id then
            raise exception 'A foreign table''s server cannot be altered.';
        end if;

        if NEW.name != OLD.name then
            execute meta.stmt_foreign_table_rename(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), OLD.name, NEW.name);
        end if;

        if NEW.options is distinct from OLD.options then
            execute meta.stmt_foreign_table_drop_options(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), NEW.name, OLD.options, NEW.options);
            execute meta.stmt_foreign_table_set_options(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), NEW.name, OLD.options, NEW.options);
            execute meta.stmt_foreign_table_add_options(coalesce(nullif(NEW.schema_name, OLD.schema_name), (NEW.schema_id).name), NEW.name, OLD.options, NEW.options);
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_table_delete() returns trigger as $$
    begin
        execute meta.stmt_foreign_table_drop(OLD.schema_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;



/******************************************************************************
 * meta.foreign_column
 *****************************************************************************/

create view meta.foreign_column as
    select meta.column_id(c.table_schema, c.table_name, c.column_name) as id,
           meta.relation_id(c.table_schema, c.table_name) as foreign_table_id,
           c.table_schema::text as schema_name,
           c.table_name::text as foreign_table_name,
           c.column_name::text as name,
           quote_ident(c.udt_schema) || '.' || quote_ident(c.udt_name) as "type",
           (c.is_nullable = 'YES') as nullable

    from pg_catalog.pg_foreign_table pft
    inner join pg_catalog.pg_class pgc
            on pgc.oid = pft.ftrelid
    inner join pg_catalog.pg_namespace pgn
            on pgn.oid = pgc.relnamespace
    inner join information_schema.columns c
            on c.table_schema = pgn.nspname and
               c.table_name = pgc.relname;


-- TODO: create function meta.foreign_column_id(...)

create function meta.stmt_foreign_column_create(
    schema_name text,
    relation_name text,
    name text,
    "type" text,
    nullable boolean
) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name)
           || ' add column ' || quote_ident(name) || ' ' || "type" || ' '
           || case when nullable then ' null'
                   else ' not null '
              end;
$$ language sql;


create function meta.stmt_foreign_column_set_not_null(schema_name text, relation_name text, name text) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(name) || ' set not null';
$$ language sql;


create function meta.stmt_foreign_column_rename(schema_name text, relation_name text, name text, new_name text) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' rename column ' || quote_ident(name) || ' to ' || quote_ident(new_name);
$$ language sql;


create function meta.stmt_foreign_column_drop_not_null(schema_name text, relation_name text, name text) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(name) || ' drop not null';
$$ language sql;


create function meta.stmt_foreign_column_set_type(schema_name text, relation_name text, name text, "type" text) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name) ||
           ' alter column ' || quote_ident(name) || ' type ' || "type";
$$ language sql;


create function meta.stmt_foreign_column_drop(
    schema_name text,
    relation_name text,
    name text
) returns text as $$
    select 'alter foreign table ' || quote_ident(schema_name) || '.' || quote_ident(relation_name)
           || ' drop column ' || quote_ident(name);
$$ language sql;


create function meta.foreign_column_insert() returns trigger as $$
    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'type']);
        perform meta.require_one(public.hstore(NEW), array['foreign_table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['foreign_table_id', 'relation_name']);

        execute meta.stmt_foreign_column_create(
            coalesce(NEW.schema_name, ((NEW.foreign_table_id).schema_id).name),
            coalesce(NEW.foreign_table_name, (NEW.foreign_table_id).name),
            NEW.name,
            NEW.type,
            NEW.nullable
        );

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_column_update() returns trigger as $$
    declare
        schema_name text;
        foreign_table_name text;

    begin
        perform meta.require_all(public.hstore(NEW), array['name', 'type']);
        perform meta.require_one(public.hstore(NEW), array['foreign_table_id', 'schema_name']);
        perform meta.require_one(public.hstore(NEW), array['foreign_table_id', 'relation_name']);


        if NEW.foreign_table_id is not null and OLD.foreign_table_id != NEW.foreign_table_id or
           NEW.schema_name is not null and OLD.schema_name != NEW.schema_name or
           NEW.foreign_table_name is not null and OLD.foreign_table_name != NEW.foreign_table_name then

            raise exception 'Moving a column to another foreign table is not supported.';
        end if;

        schema_name := OLD.schema_name;
        foreign_table_name := OLD.foreign_table_name;

        if NEW.name != OLD.name then
            execute meta.stmt_foreign_column_rename(schema_name, foreign_table_name, OLD.name, NEW.name);
        end if;

        if NEW."type" != OLD."type" then
            execute meta.stmt_foreign_column_set_type(schema_name, foreign_table_name, NEW.name, NEW."type");
        end if;

        if NEW.nullable != OLD.nullable then
            if NEW.nullable then
                execute meta.stmt_foreign_column_drop_not_null(schema_name, foreign_table_name, NEW.name);
            else
                execute meta.stmt_foreign_column_set_not_null(schema_name, foreign_table_name, NEW.name);
            end if;
        end if;

        return NEW;
    end;
$$ language plpgsql;


create function meta.foreign_column_delete() returns trigger as $$
    begin
        execute meta.stmt_foreign_column_drop(OLD.schema_name, OLD.foreign_table_name, OLD.name);
        return OLD;
    end;
$$ language plpgsql;




/******************************************************************************
 * View triggers
 *****************************************************************************/
-- SCHEMA
create trigger meta_schema_insert_trigger instead of insert on meta.schema for each row execute procedure meta.schema_insert();
create trigger meta_schema_update_trigger instead of update on meta.schema for each row execute procedure meta.schema_update();
create trigger meta_schema_delete_trigger instead of delete on meta.schema for each row execute procedure meta.schema_delete();

-- SEQUENCE
create trigger meta_sequence_insert_trigger instead of insert on meta.sequence for each row execute procedure meta.sequence_insert();
create trigger meta_sequence_update_trigger instead of update on meta.sequence for each row execute procedure meta.sequence_update();
create trigger meta_sequence_delete_trigger instead of delete on meta.sequence for each row execute procedure meta.sequence_delete();

-- TABLE
create trigger meta_table_insert_trigger instead of insert on meta.table for each row execute procedure meta.table_insert();
create trigger meta_table_update_trigger instead of update on meta.table for each row execute procedure meta.table_update();
create trigger meta_table_delete_trigger instead of delete on meta.table for each row execute procedure meta.table_delete();

-- VIEW
create trigger meta_view_insert_trigger instead of insert on meta.view for each row execute procedure meta.view_insert();
create trigger meta_view_update_trigger instead of update on meta.view for each row execute procedure meta.view_update();
create trigger meta_view_delete_trigger instead of delete on meta.view for each row execute procedure meta.view_delete();

-- COLUMN
create trigger meta_column_insert_trigger instead of insert on meta.column for each row execute procedure meta.column_insert();
create trigger meta_column_update_trigger instead of update on meta.column for each row execute procedure meta.column_update();
create trigger meta_column_delete_trigger instead of delete on meta.column for each row execute procedure meta.column_delete();

-- FOREIGN KEY
create trigger meta_foreign_key_insert_trigger instead of insert on meta.foreign_key for each row execute procedure meta.foreign_key_insert();
create trigger meta_foreign_key_update_trigger instead of update on meta.foreign_key for each row execute procedure meta.foreign_key_update();
create trigger meta_foreign_key_delete_trigger instead of delete on meta.foreign_key for each row execute procedure meta.foreign_key_delete();

-- FUNCTION_DEFINITION
create trigger meta_function_definition_insert_trigger instead of insert on meta.function_definition for each row execute procedure meta.function_definition_insert();
create trigger meta_function_definition_trigger instead of update on meta.function_definition for each row execute procedure meta.function_definition_update();
create trigger meta_function_definition_delete_trigger instead of delete on meta.function_definition for each row execute procedure meta.function_definition_delete();

-- FUNCTION
create trigger meta_function_insert_trigger instead of insert on meta.function for each row execute procedure meta.function_insert();
create trigger meta_function_update_trigger instead of update on meta.function for each row execute procedure meta.function_update();
create trigger meta_function_delete_trigger instead of delete on meta.function for each row execute procedure meta.function_delete();

-- ROLE
create trigger meta_role_insert_trigger instead of insert on meta.role for each row execute procedure meta.role_insert();
create trigger meta_role_update_trigger instead of update on meta.role for each row execute procedure meta.role_update();
create trigger meta_role_delete_trigger instead of delete on meta.role for each row execute procedure meta.role_delete();

-- ROLE INHERITANCE
create trigger meta_role_inheritance_insert_trigger instead of insert on meta.role_inheritance for each row execute procedure meta.role_inheritance_insert();
create trigger meta_role_inheritance_update_trigger instead of update on meta.role_inheritance for each row execute procedure meta.role_inheritance_update();
create trigger meta_role_inheritance_delete_trigger instead of delete on meta.role_inheritance for each row execute procedure meta.role_inheritance_delete();

-- TABLE PRIVILEGE
create trigger meta_table_privilege_insert_trigger instead of insert on meta.table_privilege for each row execute procedure meta.table_privilege_insert();
create trigger meta_table_privilege_update_trigger instead of update on meta.table_privilege for each row execute procedure meta.table_privilege_update();
create trigger meta_table_privilege_delete_trigger instead of delete on meta.table_privilege for each row execute procedure meta.table_privilege_delete();

-- POLICY
create trigger meta_policy_insert_trigger instead of insert on meta.policy for each row execute procedure meta.policy_insert();
create trigger meta_policy_update_trigger instead of update on meta.policy for each row execute procedure meta.policy_update();
create trigger meta_policy_delete_trigger instead of delete on meta.policy for each row execute procedure meta.policy_delete();

-- POLICY ROLE
create trigger meta_policy_role_insert_trigger instead of insert on meta.policy_role for each row execute procedure meta.policy_role_insert();
create trigger meta_policy_role_update_trigger instead of update on meta.policy_role for each row execute procedure meta.policy_role_update();
create trigger meta_policy_role_delete_trigger instead of delete on meta.policy_role for each row execute procedure meta.policy_role_delete();

-- CONNECTION
create trigger meta_connection_delete_trigger instead of delete on meta.connection for each row execute procedure meta.connection_delete();

-- CONSTRAINT UNIQUE
create trigger meta_constraint_unique_insert_trigger instead of insert on meta.constraint_unique for each row execute procedure meta.constraint_unique_insert();
create trigger meta_constraint_unique_update_trigger instead of update on meta.constraint_unique for each row execute procedure meta.constraint_unique_update();
create trigger meta_constraint_unique_delete_trigger instead of delete on meta.constraint_unique for each row execute procedure meta.constraint_unique_delete();

-- TYPE
create trigger meta_type_definition_insert_trigger instead of insert on meta.type_definition for each row execute procedure meta.type_definition_insert();
create trigger meta_type_definition_trigger instead of update on meta.type_definition for each row execute procedure meta.type_definition_update();
create trigger meta_type_definition_delete_trigger instead of delete on meta.type_definition for each row execute procedure meta.type_definition_delete();


-- CONSTRAINT CHECK
create trigger meta_constraint_check_insert_trigger instead of insert on meta.constraint_check for each row execute procedure meta.constraint_check_insert();
create trigger meta_constraint_check_update_trigger instead of update on meta.constraint_check for each row execute procedure meta.constraint_check_update();
create trigger meta_constraint_check_delete_trigger instead of delete on meta.constraint_check for each row execute procedure meta.constraint_check_delete();

-- TRIGGER
create trigger meta_trigger_insert_trigger instead of insert on meta.trigger for each row execute procedure meta.trigger_insert();
create trigger meta_trigger_update_trigger instead of update on meta.trigger for each row execute procedure meta.trigger_update();
create trigger meta_trigger_delete_trigger instead of delete on meta.trigger for each row execute procedure meta.trigger_delete();

-- EXTENSION
create trigger meta_extension_insert_trigger instead of insert on meta.extension for each row execute procedure meta.extension_insert();
create trigger meta_extension_update_trigger instead of update on meta.extension for each row execute procedure meta.extension_update();
create trigger meta_extension_delete_trigger instead of delete on meta.extension for each row execute procedure meta.extension_delete();

-- FOREIGN DATA WRAPPER
create trigger meta_foreign_data_wrapper_insert_trigger instead of insert on meta.foreign_data_wrapper for each row execute procedure meta.foreign_data_wrapper_insert();
create trigger meta_foreign_data_wrapper_update_trigger instead of update on meta.foreign_data_wrapper for each row execute procedure meta.foreign_data_wrapper_update();
create trigger meta_foreign_data_wrapper_delete_trigger instead of delete on meta.foreign_data_wrapper for each row execute procedure meta.foreign_data_wrapper_delete();

-- FOREIGN SERVER
create trigger meta_foreign_server_insert_trigger instead of insert on meta.foreign_server for each row execute procedure meta.foreign_server_insert();
create trigger meta_foreign_server_update_trigger instead of update on meta.foreign_server for each row execute procedure meta.foreign_server_update();
create trigger meta_foreign_server_delete_trigger instead of delete on meta.foreign_server for each row execute procedure meta.foreign_server_delete();

-- FOREIGN TABLE
create trigger meta_foreign_table_insert_trigger instead of insert on meta.foreign_table for each row execute procedure meta.foreign_table_insert();
create trigger meta_foreign_table_update_trigger instead of update on meta.foreign_table for each row execute procedure meta.foreign_table_update();
create trigger meta_foreign_table_delete_trigger instead of delete on meta.foreign_table for each row execute procedure meta.foreign_table_delete();

-- FOREIGN COLUMN
create trigger meta_foreign_column_insert_trigger instead of insert on meta.foreign_column for each row execute procedure meta.foreign_column_insert();
create trigger meta_foreign_column_update_trigger instead of update on meta.foreign_column for each row execute procedure meta.foreign_column_update();
create trigger meta_foreign_column_delete_trigger instead of delete on meta.foreign_column for each row execute procedure meta.foreign_column_delete();
/*******************************************************************************
 * Meta Helper Utilities
 * Handy functions for working with meta-related stuff.
 *
 * Copyright (c) 2019 - Aquameta - http://aquameta.org/
 ******************************************************************************/
create or replace function meta.row_exists(in row_id meta.row_id, out answer boolean) as $$
    declare
        stmt text;
    begin
        stmt := format (
            'select (count(*) = 1) from %I.%I where %I::text = %L',
                (row_id::meta.schema_id).name,
                (row_id::meta.relation_id).name,
                (row_id.pk_column_id).name,
                row_id.pk_value
            );

        -- raise warning '%s', stmt;
        execute stmt into answer;

    exception
        when undefined_table then
            answer := false;
    end;
$$ language plpgsql;


/*
create or replace function meta.row_delete(in row_id meta.row_id, out answer boolean) as $$
$$ language plpgsql;
*/
