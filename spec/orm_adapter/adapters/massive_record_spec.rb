require 'spec_helper'
require 'orm_adapter/example_app_shared'
require 'massive_record/spec/support/simple_database_cleaner'


if !defined?(MassiveRecord::ORM::Base)
  puts "** require 'massive_record' to run the specs in #{__FILE__}"
else  
  MassiveRecord::ORM::Base.connection_configuration = {:host => '127.0.0.1', :port => '9090'}

  module MassiveRecordOrmSpec

    #
    # Test classes
    #
    class User < MassiveRecord::ORM::Table
      set_table_name 'orm_adapter_users'

      column_family :base do
        field :name
        field :rating, :integer
      end

      references_many :notes, :records_starts_from => :note_ids_starts_from



      private

      def note_ids_starts_from
        "#{id}-"
      end

      def default_id
        next_id
      end
    end


    class Note < MassiveRecord::ORM::Table
      set_table_name 'orm_adapter_notes'

      column_family :base do
        field :body 
      end

      references_one :owner, :polymorphic => true, :store_in => :base


      private

      def default_id
        "owner.id-#{next_id}"
      end
    end







    
    #
    # Here be the specs! :-)
    #
    describe MassiveRecord::ORM::Base do
      include MassiveRecord::Rspec::SimpleDatabaseCleaner


      describe "the ORM adapter class" do
        subject { MassiveRecord::ORM::Base::OrmAdapter }

        its(:except_classes) { should include MassiveRecord::ORM::IdFactory }
        its(:model_classes) { should include User, Note }
        its(:model_classes) { should_not include *MassiveRecord::ORM::Base::OrmAdapter.except_classes }
      end


      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end


      describe User do
        subject { User.to_adapter }

        its(:column_names) { should include *User.attributes_schema.keys }
      end
    end
  end
end
