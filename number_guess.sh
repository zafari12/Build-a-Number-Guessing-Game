#!/bin/bash

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read INPUT

# Check if the user exists in the database
USER_NAME=$($PSQL "SELECT username FROM users WHERE username='$INPUT';")
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INPUT';")

if [[ -z $USER_NAME ]]
then
  # New user
  echo -e "Welcome, $INPUT! It looks like this is your first time here.\n"
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$INPUT');")
  # Fetch the new user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INPUT';")
else
  # Returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")
  echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# Generate the secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_NUMBER=0

echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS

# Loop until the user guesses the secret number
while [[ $USER_GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    # Input is not an integer
    echo -e "\nThat is not an integer, guess again:"
  else
    if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
    then
      echo -e "It's higher than that, guess again:"
    else
      echo -e "It's lower than that, guess again:"
    fi
  fi
  read USER_GUESS
  ((GUESS_NUMBER++))
done

# Increment for the correct guess
((GUESS_NUMBER++))

# Save the game results to the database
INSERT_RESULTS=$($PSQL "INSERT INTO games(user_id, secret_number, guesses) VALUES($USER_ID, $SECRET_NUMBER, $GUESS_NUMBER);")

# Congratulate the user
echo -e "You guessed it in $GUESS_NUMBER tries. The secret number was $SECRET_NUMBER. Nice job!"


