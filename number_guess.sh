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


SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_NUMBER=0

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS

until [[ $USER_GUESS -eq $SECRET_NUMBER ]]
do

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      # request valid guess
      echo -e"\nThat is not an integer, guess again:"
      read USER_GUESS
      # update guess count
      ((GUESS_NUMBER++))

    else
       if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
       then
          echo "It's higher than that, guess again:"
          read USER_GUESS

          ((GUESS_NUMBER++))
        else
          echo "It's lower than that, guess again:"
          read USER_GUESS

          ((GUESS_NUMBER++))
       fi
  fi
    read USER_GUESS
    ((GUESS_NUMBER++))
done

((GUESS_NUMBER++))

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME';")
INSERT_RESULTS=$($PSQL "INSERT INTO games(user_id, secret_number, guesses) VALUES($USER_ID, $SECRET_NUMBER, $GUESS_NUMBER);")

# Congratulate the user
echo -e "You guessed it in $GUESS_NUMBER tries. The secret number was $SECRET_NUMBER. Nice job!"