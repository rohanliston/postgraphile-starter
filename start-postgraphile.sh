#!/usr/bin/env sh

if [ -z "${JWT_SECRET}" ]; then
  echo "WARNING: JWT_SECRET is not set. Generating a random secret that will not be consistent for each run."
  JWT_SECRET=$(openssl rand -base64 32)
fi

./node_modules/postgraphile/cli.js \
    --plugins @graphile/pg-pubsub                                        `# pg-pubsub enables GraphQL subscriptions via PostgreSQL pub-sub.` \
    --append-plugins @graphile-contrib/pg-simplify-inflector             `# pg-simplify-inflector simplifies field names for reference fields.` \
    --port 8080                                                          `# Run on familiar port number.` \
    --connection postgresql://postgres:postgres@localhost:54322/postgres `# Database connection string.` \
    --schema app_public                                                  `# Only expose the app_public schema via GraphQL.` \
    --default-role role_anon                                             `# Use anonymous role if no bearer token is provided in the Authorization header.` \
    --jwt-secret "${JWT_SECRET}"                                         `# Secure secret for generating JWTs.` \
    --jwt-token-identifier app_public.jwt_token                          `# Type definition for generated JWTs.` \
    --enhance-graphiql                                                   `# Enhance GraphiQL with Postgraphile extensions.` \
    --allow-explain                                                      `# Support Postgres EXPLAIN output for queries.` \
    --subscriptions                                                      `# Run a websocket server for real-time subscriptions.` \
    --simple-subscriptions                                               `# Use Simple Subscriptions (see https://www.graphile.org/postgraphile/subscriptions).` \
    --watch                                                              `# Watch for changes to the database and regenerate the schema.`