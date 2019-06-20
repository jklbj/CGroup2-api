# CGroup2 API

API to store and retrieve group and calendar information

## Routes

All routes return Json

###  Root route
- GET `/`: Root route shows if Web API is running

###  user information
- GET `api/v1/accounts/[username]`: Get account details
- POST `api/v1/accounts/`: Creates a new account

###  calendar event information
- GET `api/v1/calendar_events/`: Returns all calendar event belong to an account
- POST `api/v1/calendar_events/`: Creates a new event

###  group event information
- GET `api/v1/group_events/all`: Returns all group events
- GET `api/v1/group_events/`: Returns all group events belong to an account
- POST `api/v1/group_events/`: Creates a new group event for an account
- GET `api/v1/group_events/[ID]`: Returns the group event
- DELETE `api/v1/group_events/[ID]`: Delete the group event
- PUT `api/v1/group_events/[ID]/members`: Add the member to the group
- DELETE `api/v1/group_events/[ID]/members`: Remove the member from the group

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug
Add fake data to the development database to work on this project:


```shell
rake db:seed
```

## Execute

Run this API using:

```shell
rake run:dev
```