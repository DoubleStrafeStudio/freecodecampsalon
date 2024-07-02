#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Welcome to Double's Salon ~~~"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]
  then
    echo "We have no services right now"
  else
    # echo -e "\nAvailable services"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # select a service
    echo "Please select the service you would like"
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
      then
        SERVICE_MENU "\nSorry, the service you selected does not exist."
      else
        echo "Please enter your phone number"
        read CUSTOMER_PHONE
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_ID ]]
        # if no customer id exists
        then
          # ask for name
          echo "What is your name?"
          read CUSTOMER_NAME
          # add customer to customer table
          ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          if [[ $ADD_CUSTOMER_RESULT = 'INSERT 0 1' ]]
          then
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
            echo -e "Customer '$CUSTOMER_NAME' with phone number '$CUSTOMER_PHONE' was added to the client list."
          fi
        # if customer does exist
        else
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        fi
        # if customer exists or after customer has been added, ask for a time for the service
        echo -e "Okay, $CUSTOMER_NAME, what time would you like to take care of your $SERVICE_NAME?"
        read SERVICE_TIME
        APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}


SERVICE_MENU