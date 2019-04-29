module ClientsHelper

  def internal_external_toggle_button_helper(client)
    if @client.internal?
      link_to client_path(client, client: { internal: false }), method: :put do
        content_tag :span, class: :archive do
          'Make client external'
        end
      end
    else
      link_to client_path(client, client: { internal: true }), method: :put do
        content_tag :span, class: :archive do
          'Make client internal'
        end
      end
    end
  end

end
