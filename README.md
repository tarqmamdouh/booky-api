# README

This repository is a Rails 7 application, configured as a pure API. 

It supports users, Bookings. Database is sqlite3.

This API is specially designed to work with React on the front-end: requests and responses are conformed to JSON:API.

To run the application, use the following commands:

```
bundle
rake db:create db:migrate db:seed
rails s
```
