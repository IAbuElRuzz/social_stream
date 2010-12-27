# A Relation defines a type of Tie. Relations are affective (friendship, liking, 
# respect), formal or biological (authority, kinship), transfer of material 
# resources (transactions, lending and borrowing), messages or conversations, 
# physical connection and affiliation to same organizations.
#
# == Strength hierarchies
# Relations are arranged in strength hierarchies, denoting that some ties between
# two actors are stronger than others.
# When a strong tie is established, ties with weaker relations are establised as well
#
class Relation < ActiveRecord::Base
  acts_as_nested_set

  scope :mode, lambda { |st, rt|
    where(:sender_type => st, :receiver_type => rt)
  }

  has_many :relation_permissions, :dependent => :destroy
  has_many :permissions, :through => :relation_permissions

  has_many :ties, :dependent => :destroy

  class << self
    # Get relation from object, if possible
    #
    # Options::
    # sender:: The sender of the tie
    def normalize(r, options = {})
      case r
      when Relation
        r
      when String
        if options[:sender]
          options[:sender].relation(r)
        else
          raise "Must provide a sender when looking up relations from name: #{ options[:sender] }"
        end
      when Integer
        Relation.find r
      when Array
        r.map{ |e| Relation.normalize(e, options) }
      else
        raise "Unable to normalize relation #{ r.inspect }"
      end
    end

    def normalize_id(r, options = {})
      case r
      when Integer
        r
      when Array
        r.map{ |e| Relation.normalize_id(e, options) }
      else
        normalize(r, options).id
      end
    end

    # A relation in the top of a strength hierarchy
    def strongest
      root
    end
  end

  # Other relations below in the same hierarchy that this relation
  def weaker
    descendants
  end

  # Relations below or at the same level of this relation
  def weaker_or_equal
    self_and_descendants
  end

  # Other relations above in the same hierarchy that this relation
  def stronger
    ancestors
  end

  # Relations above or at the same level of this relation
  def stronger_or_equal
    self_and_ancestors
  end

  # Relation class scoped in the same mode that this relation
  def mode
    Relation.mode(sender_type, receiver_type)
  end
end
