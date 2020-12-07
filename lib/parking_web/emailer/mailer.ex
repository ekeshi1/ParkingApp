defmodule Parking.Mailer do
  use Mailgun.Client,
      domain: "https://api.mailgun.net/v3/sandboxd6bc43eee9304e5f86d13156763f2e32.mailgun.org" ,#Parking.fetch_env!(:parking,:mailgun_domain) ,
      key: "0c10ee817bcbca1589a79ba90b28d7bf-95f6ca46-f250a3de" #Parking.fetch_env!(:parking,:mailgun_key)
      #httpc_opts: [connect_timeout: 2000, timeout: 3000,default_port: 8889]

      def send_email(email_address,sub,cont) do
        send_email to: email_address,
                  from: "mailgun@sandboxd6bc43eee9304e5f86d13156763f2e32.mailgun.org",
                  subject: sub,
                  text: cont
      end




end
