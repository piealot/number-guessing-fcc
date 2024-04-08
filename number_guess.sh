#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

# ask for username

echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

# check if user exists
if [[ -z $USER_ID ]]; then

  # if doesnt exist, welcome only
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  # if exists, check games played and best game
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# start game

RANDOM_NUMBER=$(($RANDOM % 1000 + 1))
TRIES=1

echo Guess the secret number between 1 and 1000:
read GUESS

# continue while guess is not correct
while [[ $GUESS != $RANDOM_NUMBER ]]; do

  # increment tries counter
  ((TRIES += 1))

  # check if input is a number
  if [[ $GUESS =~ ^[0-9]+$ ]]; then
    if [[ $GUESS < $RANDOM_NUMBER ]]; then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  else
    echo That is not an integer, guess again:
  fi
  read GUESS
done

echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"

# if user existed update entry, if not enter new user
if [[ -z $USER_ID ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(name,games_played,best_game) VALUES('$USERNAME', 1, $TRIES)")
else
  if [ $TRIES -lt $BEST_GAME ]; then
    BEST_GAME=$TRIES
  fi
  UPDATE_USER=$($PSQL "UPDATE users SET best_game=$BEST_GAME, games_played=$((++GAMES_PLAYED)) WHERE name='$USERNAME'")
fi
