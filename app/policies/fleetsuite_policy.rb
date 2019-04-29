class FleetsuitePolicy

  ROLES = ['account_holder', 'administrator', 'leader', 'member']

  def method_missing(meth, *args, &blk)
    raise ArgumentError, "#{ meth.capitalize } is not a valid user role" unless ROLES.include? meth.to_s
    @user.includes_role? [meth.to_s]
  end

  def respond_to?(method, include_private = false)
    super || ROLES.include?(method.to_s)
  end

end