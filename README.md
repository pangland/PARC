# PARC (Paul's ActiveRecord Clone)
---
PARC is an ActiveRecord-inspired lightweight library that allows for updates and associations to be made in a SQLite3 database without writing much SQL.

## Instructions
---
Requirements:
- Ruby
- SQLite3 gem

1. Download and clone this repo
2. Run `bundle install` to download the relevant gems.
3. Navigate to the demo folder, open pry, and load `demo.rb`
4. You can now run your favorite methods to look at the database and relations (methods below).

## Demo Material
---
The `./demo/demo.rb` file contains the sample associations and model classes. The sample database features martial arts styles, practitioners, techniques, and the relations between them. You should be able to check a martial artist's lineal grandmaster, a style's practitioners, and so on. The method names for the associations are in the demo file.

## Features
- `#all` returns all entries in a table
- `#find` locates an entry in a table by its id
- `#first` returns the first entry in a table
- `#last` returns the last entry in a table
- `#insert` inserts an entry into a table
