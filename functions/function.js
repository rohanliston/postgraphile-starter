/**
 * Example of how we can implement additional business logic
 * using cloud functions.
 *
 * This example LISTENs for a NOTIFY that is triggered each time
 * a user is registered. See the example_trigger migration for reference.
 *
 * If the caller needs to know the result of this function, they can
 * use GraphQL subscriptions to listen for an event triggered by this function.
 *
 * e.g.
 * "INSERT INTO user" ==> "user_registered" ==> (this function) ==> "NOTIFY postgraphile:registration_complete" ==> graphql subscription
 */

const pg = require("pg");

const config = {
  user: "postgres",
  password: "postgres",
  host: "localhost",
  port: 54322,
  db: "postgres",
};

// Connect to the database and listen for the event we are interested in.
const connectionString = `postgres://${config.user}:${config.password}@${config.host}:${config.port}/${config.db}`;
const client = new pg.Client(connectionString);
client.connect();
client.query("LISTEN user_registered");

// Handle events triggered by NOTIFY.
client.on("notification", async (data) => {
  const payload = JSON.parse(data.payload);
  const { id, email } = payload.record;
  console.log(`User ${id} registered with email ${email}`);

  // Simulate doing some business logic and sending a notification
  // that the caller can listen for.
  console.log("Doing some business logic...");
  console.log("Sending postgraphile:registration_complete notification...");

  // Postgraphile "Simple Subscriptions" listens for notifications
  // with the "postgraphile:" prefix.
  const responseTopic = "postgraphile:registration_complete";

  // We can construct a response payload that will be used by Postgraphile
  // to automatically fetch records from the database into the `relatedNode` field.
  const responsePayload = {
    __node__: [
      // IMPORTANT: This is not always exactly the table name;
      // base64 decode an existing nodeId to see what it should be.
      "users",
      // The primary key (for multiple keys, list them all).
      id,
    ],
  };

  // Send the notification.
  client.query(
    `NOTIFY "${responseTopic}", '${JSON.stringify(responsePayload)}'`
  );
});
