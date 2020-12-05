defmodule Parking.Mailer do
  use Mailgun.Client,
      domain: "3" ,#Parking.fetch_env!(:parking,:mailgun_domain) ,
      key: "0c10ee817bcbca1589a79ba90b28d7bf-95f6ca46-f250a3de" #Parking.fetch_env!(:parking,:mailgun_key)


      def send_email(email_address,sub,cont) do
        send_email to: email_address,
                  from: "us@example.com",
                  subject: sub,
                  text: cont
      end




end
