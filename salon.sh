#! /bin/bash 

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  SERVICES 

}

SERVICES() {
  if [[ $1 ]]; then 
    echo -e "\n$1" 
  fi

  SERV=$($PSQL "select service_id, name from services order by service_id")

  echo "$SERV" | while read SERVICE_ID BAR NAME 
  do 
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED 

  SERV_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $SERV_NAME ]]; then
    SERVICES "I could not find that service. What would you like today?"
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]; then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like your $SERV_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

      INSERT_APP=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERV_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else 
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like your $SERV_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_APP=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERV_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}


MAIN_MENU 
