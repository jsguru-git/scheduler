options = { color: 'green', message_format: 'html', message: "<strong>#{ config.deployed_by }</strong> successfully deployed <strong><a href='https://github.com/arthurly/scheduling/tree/#{ config.input_ref }'>#{ config.input_ref }</a></strong> to <strong>#{ config.environment_name.upcase }</strong>" }.to_json
command = "curl -H \"Accept: application/json\" -H \"Content-type: application/json\" -X POST -d '#{ options }'  https://api.hipchat.com/v2/room/FleetSuite/notification?auth_token=h5lfvHxeOIPrb7EwhnzV96LW9erlmAin3XxIHtvx"
run command
