apt-get update
apt-get install -y cpanminus sqlite3 zip libssl-dev
cpanm DBI DBD::SQLite Data::Faker Data::Structure::Util Date::Manip Digest::SHA1 JSON::XS Lingua::EN::Inflexion
