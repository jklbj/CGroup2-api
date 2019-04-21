# CGroup2

API to store and retrieve confidential development files (configuration, events)

## Routes

All routes return Json

###  Root route
- GET `/`: Root route shows if Web API is running

###  user information
- GET `api/v1/users/`: returns all users' IDs
- GET `api/v1/users/[ID]`: returns details about a single user with given ID
- POST `api/v1/users/`: creates a new user

###  calendar event information
- GET `api/v1/users/[ID]/calendar_events/`: returns all calendar event IDs
- GET `api/v1/users/[ID]/calendar_events/[ID]`: returns details about a single calendar event with given ID
- POST `api/v1/users/[ID]/calendar_events/`: creates a new event

###  group event information
- GET `api/v1/users/[ID]/group_events/`: returns all group event IDs
- GET `api/v1/users/[ID]/group_events/[ID]`: returns details about a single group event with given ID
- POST `api/v1/users/[ID]/group_events/`: creates a new group event

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```