defmodule Parking.Mailer do
  use Mailgun.Client,
      domain: "3" ,#Parking.fetch_env!(:parking,:mailgun_domain) ,
      key: "3" #Parking.fetch_env!(:parking,:mailgun_key)


      def send_email(email_address,sub,cont) do
        send_email to: email_address,
                  from: "us@example.com",
                  subject: sub,
                  text: cont
      end




end
