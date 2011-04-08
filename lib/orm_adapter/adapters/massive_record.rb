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



    def column_names
      klass.attributes_schema.keys
    end



    def create!(attributes = {})
      klass.create!(attributes)
    end

    def get!(id)
      klass.find(wrap_key(id))
    end

    def get(id)
      klass.find(wrap_key(id))

      rescue MassiveRecord::ORM::RecordNotFound
        nil
    end

    def find_first(options = {})
      conditions, order = extract_conditions_and_order!(options)
      klass.first(:conditions => conditions, :order => order)
    end

    def find_all(options = {})
      conditions, order = extract_conditions_and_order!(options)
      klass.all(:conditions => conditions, :order => order)
    end
  end
end
