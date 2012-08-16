require 'spec_helper'

describe "Client API operations", type: "acceptance" do
  let(:server_url) { "https://api.opscode.com" }
  let(:client_name) { "reset" }
  let(:client_key) { "/Users/reset/.chef/reset.pem" }
  let(:organization) { "vialstudios" }

  let(:connection) do
    Ridley.connection(
      server_url: server_url,
      client_name: client_name,
      client_key: client_key,
      organization: organization
    )
  end

  before(:all) { WebMock.allow_net_connect! }
  after(:all) { WebMock.disable_net_connect! }

  before(:each) do
    connection.start { client.delete_all }
  end

  describe "finding a client" do
    let(:target) do
      Ridley::Client.new(
        name: "motherbrain-test",
        admin: false
      )
    end

    before(:each) do
      connection.start { client.create(target) }
    end

    it "returns a valid Ridley::Client" do
      connection.start do
        obj = client.find(target)

        obj.should be_a(Ridley::Client)
        obj.should be_valid
      end
    end
  end

  describe "creating a client" do
    let(:target) do
      Ridley::Client.new(
        name: "motherbrain_test"
      )
    end

    it "returns a Ridley::Client object" do
      connection.start do
        client.create(target).should be_a(Ridley::Client)
      end
    end

    it "has a value for 'private_key'" do
      connection.start do
        client.create(target).private_key.should_not be_nil
      end
    end
  end

  describe "deleting a client" do
    let(:target) do
      Ridley::Client.new(
        name: "motherbrain-test",
        admin: false
      )
    end

    before(:each) do
      connection.start { client.create(target) }
    end

    it "returns a Ridley::Client object" do
      connection.start do
        client.delete(target).should be_a(Ridley::Client)
      end
    end
  end

  describe "deleting all clients" do
    before(:each) do
      connection.start do
        client.create(name: "ridley-one")
        client.create(name: "ridley-two")
      end
    end

    it "returns an array of Ridley::Client objects" do
      connection.start do
        client.delete_all.should each be_a(Ridley::Client)
      end
    end

    it "deletes all clients from the remote" do
      connection.start do
        client.delete_all

        client.all.should have(0).clients
      end
    end
  end

  describe "listing all clients" do
    it "returns an array of Ridley::Client objects" do
      connection.start do
        client.all.should each be_a(Ridley::Client)
      end
    end
  end

  describe "regenerating a client's private key" do
    let(:target) do
      Ridley::Client.new(
        name: "motherbrain-test",
        admin: false
      )
    end

    before(:each) do
      connection.start { client.create(target) }
    end

    it "returns a Ridley::Client object with a value for 'private_key'" do
      connection.start do
        obj = client.regenerate_key(target)

        obj.private_key.should match(/^-----BEGIN RSA PRIVATE KEY-----/)
      end
    end
  end
end
