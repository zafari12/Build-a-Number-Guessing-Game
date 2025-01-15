#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read INPUT

USER_NAME=$($PSQL "SELECT username FROM users WHERE username='$INPUT';")
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INPUT';")

if [[ -z $USER_NAME ]]
then
  echo -e "Welcome, $INPUT! It looks like this is your first time here.\n"
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$INPUT');")

else
   GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USER_NAME';")
   BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games LEFT JOIN users USING(user_id) WHERE username='$USER_NAME';")

   echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi