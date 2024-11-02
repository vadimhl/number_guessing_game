#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL="psql --dbname=number_guess -t --no-align -c"

echo Enter your username:
read NAME
if [[ -z $NAME ]]
then
  exit
else
  USER_ID=$($PSQL "select user_id 
                   from users 
                   where name = '$NAME'")
  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $NAME! It looks like this is your first time here."
    INSERT_RESULT=$($PSQL "insert into users(name) 
                           values('$NAME') 
                           RETURNING user_id")
    USER_ID=$(echo $INSERT_RESULT | sed -r 's/([0-9]+).*/\1/')
  else
    GAMES_INFO=$($PSQL "SELECT count(*), min(guesses) 
                        from games 
                        where user_id = $USER_ID")
    GAMES=$(echo $GAMES_INFO | sed -r 's/^([0-9]+)\|.*/\1/')
    BEST_GAME=$(echo $GAMES_INFO | sed -r 's/.*\|([0-9]+)$/\1/')
    echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST_GAME guesses."
  fi
  SECRET=$(( RANDOM % 1000 + 1 ))
  echo Guess the secret number between 1 and 1000:
  read GUESS
  GUESSES=1
  while [[ $GUESS != $SECRET ]]
  do
    if [[ $GUESS < $SECRET ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    read GUESS
    ((GUESSES++))
  done
  INSERT_RESULT=$($PSQL "insert into games (user_id, secret, guesses)
                         values ($USER_ID, $SECRET, $GUESSES)")
  echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
  
fi