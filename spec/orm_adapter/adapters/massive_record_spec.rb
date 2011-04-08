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

      references_many :notes, :class_name => "MassiveRecordOrmSpec::Note", :store_in => :base



      private

      def default_id; next_id; end
    end


    class Note < MassiveRecord::ORM::Table
      set_table_name 'orm_adapter_notes'

      column_family :base do
        field :body 
      end

      references_one :owner, :polymorphic => true, :store_in => :base


      private

      def default_id; next_id; end
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


      describe "a spesific (user) adapter" do
        subject { User.to_adapter }
        its(:column_names) { should include *User.attributes_schema.keys }
      end


      it_should_behave_like "example app with orm_adapter", :skip_tests => [:find_first, :find_all] do
        let(:user_class) { User }
        let(:note_class) { Note }
      end


      describe "#find_first" do
        subject { User.to_adapter }
        let(:conditions) { {:is_not => :supported_out_of_the_box} }
        let(:order) { [:name, :desc] }

        it "should send conditions on when calling ORM's first" do
          User.should_receive(:first).with(hash_including(:conditions => conditions)) 
          subject.find_first(conditions)
        end

        it "should send conditions on when calling ORM's first, conditions given as nested hash" do
          User.should_receive(:first).with(hash_including(:conditions => conditions)) 
          subject.find_first(:conditions => conditions)
        end

        it "should send order on when calling ORM's first" do
          User.should_receive(:first).with(hash_including(:order => [order]))
          subject.find_first(:order => order)
        end
      end


      describe "#find_all" do
        subject { User.to_adapter }
        let(:conditions) { {:is_not => :supported_out_of_the_box} }
        let(:order) { [:name, :desc] }

        it "should send conditions on when calling ORM's all" do
          User.should_receive(:all).with(hash_including(:conditions => conditions)) 
          subject.find_all(conditions)
        end

        it "should send conditions on when calling ORM's all, conditions given as nested hash" do
          User.should_receive(:all).with(hash_including(:conditions => conditions)) 
          subject.find_all(:conditions => conditions)
        end

        it "should send order on when calling ORM's all" do
          User.should_receive(:all).with(hash_including(:order => [order]))
          subject.find_all(:order => order)
        end
      end
    end
  end
end
