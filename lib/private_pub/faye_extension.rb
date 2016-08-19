module PrivatePub
  # This class is an extension for the Faye::RackAdapter.
  # It is used inside of PrivatePub.faye_app.
  class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)
      p "uid message for subscription = #{message.inspect}"
      p "Class query: #{ChatUser.superclass}"
      if message["channel"] == "/meta/subscribe"
        authenticate_subscribe(message)
        uid = message['ext']['user_id']
        pid = message['ext']['project_id']
        cid = message['ext']['clientId']
        if uid && pid && cid && uid != 0 && pid != 0
           update_online_status(uid, pid, cid)
        end
      elsif message["channel"] !~ %r{^/meta/}
        authenticate_publish(message)
      end
      callback.call(message)
    end

  private

    # Ensure the subscription signature is correct and that it has not expired.
    def authenticate_subscribe(message)
      subscription = PrivatePub.subscription(:channel => message["subscription"], :timestamp => message["ext"]["private_pub_timestamp"], :user_id => message["ext"]["user_id"] )
      if message["ext"]["private_pub_signature"] != subscription[:signature]
        p "ERROR: user #{message["ext"]["user_id"]} have incorrect signature"
        message["error"] = "Incorrect signature."
      elsif PrivatePub.signature_expired? message["ext"]["private_pub_timestamp"].to_i
        message["error"] = "Signature has expired."
      end
    end

    # Ensures the secret token is correct before publishing.
    def authenticate_publish(message)
      if PrivatePub.config[:secret_token].nil?
        raise Error, "No secret_token config set, ensure private_pub.yml is loaded properly."
      elsif message["ext"]["private_pub_token"] != PrivatePub.config[:secret_token]
        message["error"] = "Incorrect token."
      else
        message["ext"]["private_pub_token"] = nil
      end
    end
    
    def update_online_status(uid, pid, cid)
      p "Class query: #{uid},#{pid},#{cid},"
      p "Class query: #{ChatUser.superclass}"
    end
  end
end
