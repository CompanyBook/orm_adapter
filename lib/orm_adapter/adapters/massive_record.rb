require 'massive_record'

class MassiveRecord::ORM::Base
  extend OrmAdapter::ToAdapter

  class OrmAdapter < ::OrmAdapter::Base
    def self.except_classes
      @@except_classes ||= [
        ::MassiveRecord::ORM::IdFactory
      ]
    end

    def self.model_classes
      ::MassiveRecord::ORM::Table.descendants - except_classes
    end
  end
end
