module CustomReportHelper
  private

  def custom_filter(collection)
    collection.filter_by_label(selected_label)
              .filter_by_team(selected_team)
              .filter_by_inbox(selected_inbox)
              .filter_by_rating(selected_rating)
  end

  def get_filter(key)
    filter = params.dig(:custom_filter, key)
    return [] if filter.blank?

    filter.to_unsafe_h.values
  end

  def selected_label
    get_filter(:selected_label)
  end

  def selected_team
    get_filter(:selected_team)
  end

  def selected_inbox
    get_filter(:selected_inbox)
  end

  def selected_rating
    get_filter(:selected_rating)
  end
end
