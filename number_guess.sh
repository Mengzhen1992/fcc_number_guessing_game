#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get a username as input
echo Enter your username:
read USERNAME

# check a username exists or not
USERNAME_DATABASE=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")


if [[ -z $USERNAME_DATABASE ]]
then 
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else 
  GAME_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
  BEST_GUESS=$($PSQL "SELECT MIN(guess) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
  echo Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GUESS guesses.
fi

# generate a number
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=1

# guess a number
echo Guess the secret number between 1 and 1000:
read GUESS

until [[ $GUESS == $RANDOM_NUMBER ]]
do 
  # check the number is an integer or not
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then 
    echo "That is not an integer, guess again:"
    read GUESS
    ((GUESS_COUNT++))
  else 
    if [[ $GUESS > $RANDOM_NUMBER ]]
    then 
      echo "It's lower than that, guess again:"
      read GUESS
      ((GUESS_COUNT++))
    elif [[ $GUESS < $RANDOM_NUMBER ]]
    then 
      echo "It's higher than that, guess again:"
      read GUESS
      ((GUESS_COUNT++))
    fi
  fi
done

# insert data from game into database
USER_ID_DATABASE=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_USER_ID_GUESS=$($PSQL "INSERT INTO games(user_id, guess) VALUES($USER_ID_DATABASE, $GUESS_COUNT)")
echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
