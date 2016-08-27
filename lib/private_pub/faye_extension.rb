module PrivatePub
  # This class is an extension for the Faye::RackAdapter.
  # It is used inside of PrivatePub.faye_app.
  class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)
      # process the disconnect condistion
      if message["channel"] == "/meta/disconnect"
        cid = message['clientId']
        if cid
           offline_status(cid)
        end
      end
      if message["channel"] == "/meta/subscribe"
        authenticate_subscribe(message)
        uid = message['ext']['user_id']
        pid = message['ext']['project_id']
        cid = message['clientId']
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
      subscription = PrivatePub.subscription(:channel => message["subscription"], :timestamp => message["ext"]["private_pub_timestamp"], :user_id => message["ext"]["user_id"], :project_id => message["ext"]["project_id"] )
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
    
    def offline_status(cid)
      chat_user = ChatUser.find_by :client_id => cid
      if !chat_user.blank?
        uid = chat_user.user_id
        pid = chat_user.project_id
        chat_users = ChatUser.where :project_id => pid, :user_id => uid
        if !chat_users.blank?
          chat_users.destroy_all
        end
      end
    end
    
    def update_online_status(uid, pid, cid)
      chat_users = ChatUser.where :project_id => pid, :user_id => uid
      if chat_users.blank?
        ChatUser.create(:client_id => cid, :user_id => uid, :project_id => pid )
      else
        chat_users.each do |chat_user|
          chat_user.update_attribute(:client_id, cid)
        end
      end
    end
  end
end
