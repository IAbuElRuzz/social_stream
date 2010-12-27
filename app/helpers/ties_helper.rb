module TiesHelper
  def tie_brief(tie)
    "N contacts in common"
  end

  # Show current ties from current user to actor, if they exist, or provide a link
  # to create a new tie to actor
  def ties_to(a)
    if user_signed_in?
      if current_user.ties_to(a).present?
        current_user.ties_to(a).first.relation_name
      else
        new_tie_link(current_user.sent_ties.build :receiver_id => Actor.normalize_id(a))
      end
    else
      link_to t("contact.new.link"), new_user_session_path
    end
  end

  def new_tie_link(tie)
    link_to t("contact.new.link"),
            new_tie_path("tie[sender_id]" => tie.sender.id,
                         "tie[receiver_id]" => tie.receiver.id),
            :title => t("contact.new.title",
                        :name => tie.receiver_subject.name),
            :remote => true
  end

  def link_follow_state
      link_to("Unfollow", home_path)
  end
end
