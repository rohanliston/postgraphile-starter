# Postgraphile evaluation

Demonstrates the use of [Postgraphile](https://www.graphile.org/postgraphile/) to serve a [GraphQL](https://graphql.org/) API from an existing [PostgreSQL](https://www.postgresql.org/) schema, offering a single source of truth for a project's entire data model and security.

## Getting started

### Run PostgreSQL

_NOTE: The DB is currently provided by [Supabase](https://supabase.com) because I was evaluating it to begin with. Will be replaced with Docker/Flyway soon._

* Install the [Supabase CLI](https://github.com/supabase/cli).
* Run `supabase start` to run the Postgres database (among other things).
* Run `supabase db reset` to reset the DB if you ever need to.

### Run Postgraphile

* Run `npm install` to fetch dependencies.
* Run `npm run postgraphile` to run Postgraphile.

### Authenticate or register a user

* Visit http://localhost:8080/graphiql to interact with the GraphQL schema.
* Submit the `authenticate` mutation using a username and password. Users are:
  * `george@vandelayindustries.com`:`george` (user)
  * `elaine@peterman.com`:`elaine` (user)
  * `newman@uspost.com`:`newman` (admin)
* Copy the `jwtToken` value from the response and add it to the GraphiQL request headers, e.g. `{"Authorization": "Bearer PASTE_TOKEN_VALUE_HERE"}`
* If you wish to register a new user instead, use the `register` mutation (supply a name, email, and password), then follow the above steps using the new login details.

## Schema

This project models the `User <--> Member <--> Organisation` pattern that crops up in many projects.

To demonstrate RLS policies in action:
* User `George Costanza` belongs to `Vandelay Industries` and can see all other `members` of his `organisation`.
* He can see all `product`s that have been 'published' by all organisations.
* He can see his organisation's 'unpublished' products.
* The same applies to `Elaine Benes`, but she works for `Peterman Catalog`.
* `Newman` is an admin and reads your mail, so he can see everything.

## Security

### Separate schemas

Separate schemas are used to control exactly what is exposed to the GraphQL API:

* `app_public`: All tables and functions are exposed to GraphQL. Fine-grained access is defined via [Row-Level Security (RLS)](https://www.postgresql.org/docs/current/ddl-rowsecurity.html) policies as described below.
* `app_hidden`: Used for internal tables and functions that are not sensitive, but should not be exposed to GraphQL clients.
* `app_private`: For sensitive data (e.g. passwords, access tokens) that is by design impossible for web users to access.

### User authentication

Authentication is implemented using Postgraphile's JWT support. New users register with a `register` mutation and existing users obtain a token using an `authenticate` mutation.

Login details are stored in a `login` table in the `app_private` schema. Passwords are encrypted and salted using [bcrypt](https://auth0.com/blog/hashing-in-action-understanding-bcrypt/).

### RBAC for coarse-grained data security

Coarse-grained access to data is controlled by `GRANT`ing privileges to a set of roles:

* `role_anon`: Assigned to all users by default. All this role can do is `register` or `authenticate`.
* `role_user`: Regular user role. Has access to CRUD all `app_public` tables and execute all `app_public` functions, subject to RLS policies (which deny by default).
* `role_admin`: Has unrestricted access to all tables and functions in the `app_public` schema and is not subject to RLS policies. Still cannot see anything outside of the public schema.

### RLS for fine-grained data security

Fine-grained access to data is controlled by Row-Level Security policies. These policies define exactly what a particular user should be able to see and do, and will automatically filter query results.

## Custom queries and mutations

Adding a custom query/mutation is as simple as adding a function to the `app_public` schema. Functions marked as `STABLE` will become queries, and others will become mutations.

Functions can be written in SQL (preferred for best performance), PLPGSQL (more flexible), or any other supported language such as JavaScript (plv8).

## Custom business logic

In many cases, an SQL/PLPGSQL function will suffice for any non-CRUD business logic. Otherwise, it is possible to use Postgres' [LISTEN/NOTIFY](https://www.postgresql.org/docs/current/sql-notify.html) feature to execute cloud functions in any language.

## Subscriptions

Postgraphile supports [subscriptions](https://www.graphile.org/postgraphile/subscriptions/) and [live queries](https://www.graphile.org/postgraphile/live-queries/) for updating data as it changes in the database. Currently, only subscriptions is enabled.