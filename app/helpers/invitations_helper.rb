module InvitationsHelper

  ORDER_FILTERS = [
    ['Nome', { s: 'name asc' }],
    ['Data Criação', { s: 'created_at desc' }]
  ]

  def order_filters_invitation
    filters(ORDER_FILTERS)
  end

  def filters(options)
    options.map do |label, filter|
      content_tag(:li) do
        link_to_unless_current label, params_with_filter(filter) do
          link_to label, params_without_filter(filter), class: 'is-active'
        end
      end
    end.join.html_safe
  end

  def params_with_filter(filter_hash)
    params_yield_filter do |ransack_query|
      ransack_query.merge!(filter_hash)
    end
  end

  def params_yield_filter
    params.permit(q: [params[:q]&.keys]).to_h.deep_dup.tap do |params_copy|
      params_copy[:q] ||= {}
      yield params_copy[:q]
      params_copy
    end
  end

  def instructions_error(invitation)
    return if invitation.errors&.messages&.dig(:instructions).blank?
    content_tag(:div, class: 'notification is-danger') do
      content_tag(:button, class: 'delete') do
      end + invitation.errors.messages[:instructions].join
    end
  end

end
