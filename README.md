# CGroup2

API to store and retrieve confidential development files (configuration, events)

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/group_event/`: returns all event IDs
- GET `api/v1/group_event/[ID]`: returns details about a single event with given ID
- POST `api/v1/group_event/`: creates a new event

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