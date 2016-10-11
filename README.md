# Todo

##Background

This is a simple Todo API implemented using the Phoenix Web framework
and Elixir programming language. It's just a learning exercise.

##To start the app

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

##Docker

A `Dockerfile` and `docker-compose.yml` can be used to run the
development environment inside a docker container. Assuming you've got a
working installation of Docker and Docker compose you just need to run
to run the application (and a separate container running Postgres):

    $ docker-compose up

You may need to set up a database, e.g.:

    $ docker-compose run web mix ecto:create
    $ docker-compose run web mix ecto:migrate

To run the tests in Docker:

    $ docker-compose run web mix test
