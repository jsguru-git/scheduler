require 'openssl'  
require 'base64'  

class PGP
  
  # Public: initialize
  def initialize(password=APP_CONFIG['pgp_key'], public_filename='public1024.pem', private_filename='private1024.pem')
    @password = password
    @public_key_file =  "#{Rails.root}/config/keys/" + public_filename
    @private_key_file = "#{Rails.root}/config/keys/" + private_filename
  end
  
  # Public: Encrypt string
  # String {string}
  def encrypt(string)
    Base64.encode64(public_key.public_encrypt(string)).gsub("\n","")
  end
  
  # Public: Decrypt string
  # String {string}
  def decrypt(string)
    private_key.private_decrypt(Base64.decode64(string))    
  end

private  

  # Private: Load public key
  def public_key
    @public_key ||= load_key(@public_key_file)
  end

  # Public: Load private key
  def private_key
    @private_key ||= load_key(@private_key_file)
  end

  # Private: load a key
  def load_key(key_file)
    OpenSSL::PKey::RSA.new(File.read(key_file), @password)
  end
  
end
