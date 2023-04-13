# AttendanceService

## Introduce

A backend & analyzer service support for school to management (present, absent, fever) kids. Service is written by Elixir programming language.

## Architecture

Service has three main application and an traffic simulator app for test workload.

Main applications: Frontend API, Db service, Dashboard.
Test application: traffic simulator.

### Frontend API

An Rest API endpoint. Receives data from client (mobile, web app) verify security and data then send to Db service.

### Db service

An pure Elixir/Erlang database (use ETS & Mnesia). Receives data from Frontand API app throught a queue and storage to Mnesia.

Service has a realtime filter for fast detecting fever to alert to admin.

Other task is anlysis data per(day, week, month) after received a job.

### Dashboard service

Loads data from Db service then show to admin. Data from alert is realtime, other data is loaded after Db service run analyzer job.

The app has planed use Phoenix for dashboard, LiveView for realtime alert.

**service in incomplete.**

*Note: For detail of each app/service please go to README.md in app folder.*