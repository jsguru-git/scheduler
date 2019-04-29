# Methods to help with account plan limits and checking
module PlanChecker


    # includes
    def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
    end


    # Instance method
    module InstanceMethods


        #
        # Check if plan has reached limit for the class (used on validations)
        def has_reached_plan_limit?
            unless self.account.blank?
                current_count = self.class.name.camelize.constantize.count(:conditions => ["account_id = ?", self.account_id])
                table_name = self.class.name.camelize.constantize.table_name
                archived_users = self.account.users.where(archived: true).count

                if self.account.account_plan.send('no_' + table_name) != nil && (current_count - archived_users) >= self.account.account_plan.send('no_' + table_name)
                    return true
                else
                    return false
                end
            end
        end


        #
        # Sends an email to the account holder if limit has been reached for the first time since an account plan change
        def send_reached_plan_limit_email
            account = self.account
            unless account.account_setting.reached_limit_email_sent
                # Send email
                account_user = User.account_holder_for_account(account)
                AccountMailer.plan_limit_reached_notification(account_user).deliver
                # Mark as sent
                account.account_setting.mark_as_reached_limit_email_sent
            end
        end


    end


    # Class methods
    module ClassMethods


        #
        # Check if plan will reach a limit if x amount of additional records are added
        def will_exceed_plan_limit_if_additional_added?(account, additional_records = 0)
            current_count = self.name.camelize.constantize.count(:conditions => ["account_id = ?", account.id])
            table_name = self.name.camelize.constantize.table_name

            if account.account_plan.send('no_' + table_name) != nil && (current_count + additional_records) > account.account_plan.send('no_' + table_name)
                return true
            else
                return false
            end
        end


    end


end
