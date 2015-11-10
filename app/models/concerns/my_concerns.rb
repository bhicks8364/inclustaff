module MyConcerns
  extend ActiveSupport::Concern

  included do
      puts "YAY!"
    scope :deleted, ->{ where.not(deleted_at: nil) }
    scope :without_deleted, ->{ where(deleted_at: nil) }
    scope :with_deleted, ->{ unscope(where: :deleted_at) }

    default_scope { without_deleted }
  end

  def destroy(mode=:soft)
    if mode == :hard
      super()
    else
      update(deleted_at: Time.zone.now)
    end
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at?
  end
end