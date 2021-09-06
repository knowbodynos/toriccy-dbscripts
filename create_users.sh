#!/bin/bash

mongo -u ${username} -p ${password} --authenticationDatabase admin --eval "db.createUser({"user":"dbadmin","pwd":"kreuzerskarke","roles":[{"role":"root","db":"admin"}]});db.createUser({"user":"manager","pwd":"toric","roles":[{"role":"readWrite","db":"ToricCY"}]});db.createUser({"user":"frontend","pwd":"password","roles":[{"role":"read","db":"ToricCY"}]});"

