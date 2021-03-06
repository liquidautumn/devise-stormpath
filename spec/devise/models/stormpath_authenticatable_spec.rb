require "spec_helper"
require "devise/models/stormpath_authenticatable"


describe Devise::Models::StormpathAuthenticatable do
  class User
    class << self
      %w{attr_accessible after_initialize before_create before_update after_destroy}.each do |method_name|
        define_method method_name do |*args|
        end
      end
    end
    include Devise::Models::StormpathAuthenticatable
  end

  let(:user) { mock("user") }

  describe "::authenticate_with_stormpath" do
    it "should return user if authenticated on stormpath and local user exists with returned href" do
      Stormpath::Rails::Client.should_receive(:authenticate_account).with("username", "password").and_return(mock("account", get_href: "user href"))
      User.should_receive(:where).with(stormpath_url: "user href").and_return([user])
      User.authenticate_with_stormpath(username: 'username', password: "password").should == user
    end

    it "should return nil if authenticated on stormpath but no local user exists" do
      Stormpath::Rails::Client.should_receive(:authenticate_account).with("username", "password").and_return(mock("account", get_href: "user href"))
      User.should_receive(:where).with(stormpath_url: "user href").and_return([])
      User.authenticate_with_stormpath(username: 'username', password: "password").should == nil
    end

    it "should return nil if stormpath authentication failed" do
      Stormpath::Rails::Client.should_receive(:authenticate_account).with("username", "password").and_raise(ResourceError.new("Error"))
      User.authenticate_with_stormpath(username: 'username', password: "password").should == nil
    end
  end
end
