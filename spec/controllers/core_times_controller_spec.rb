require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe CoreTimesController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # CoreTime. As you add validations to CoreTime, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CoreTimesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all core_times as @core_times" do
      core_time = CoreTime.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:core_times)).to eq([core_time])
    end
  end

  describe "GET show" do
    it "assigns the requested core_time as @core_time" do
      core_time = CoreTime.create! valid_attributes
      get :show, {:id => core_time.to_param}, valid_session
      expect(assigns(:core_time)).to eq(core_time)
    end
  end

  describe "GET new" do
    it "assigns a new core_time as @core_time" do
      get :new, {}, valid_session
      expect(assigns(:core_time)).to be_a_new(CoreTime)
    end
  end

  describe "GET edit" do
    it "assigns the requested core_time as @core_time" do
      core_time = CoreTime.create! valid_attributes
      get :edit, {:id => core_time.to_param}, valid_session
      expect(assigns(:core_time)).to eq(core_time)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CoreTime" do
        expect {
          post :create, {:core_time => valid_attributes}, valid_session
        }.to change(CoreTime, :count).by(1)
      end

      it "assigns a newly created core_time as @core_time" do
        post :create, {:core_time => valid_attributes}, valid_session
        expect(assigns(:core_time)).to be_a(CoreTime)
        expect(assigns(:core_time)).to be_persisted
      end

      it "redirects to the created core_time" do
        post :create, {:core_time => valid_attributes}, valid_session
        expect(response).to redirect_to(CoreTime.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved core_time as @core_time" do
        post :create, {:core_time => invalid_attributes}, valid_session
        expect(assigns(:core_time)).to be_a_new(CoreTime)
      end

      it "re-renders the 'new' template" do
        post :create, {:core_time => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested core_time" do
        core_time = CoreTime.create! valid_attributes
        put :update, {:id => core_time.to_param, :core_time => new_attributes}, valid_session
        core_time.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested core_time as @core_time" do
        core_time = CoreTime.create! valid_attributes
        put :update, {:id => core_time.to_param, :core_time => valid_attributes}, valid_session
        expect(assigns(:core_time)).to eq(core_time)
      end

      it "redirects to the core_time" do
        core_time = CoreTime.create! valid_attributes
        put :update, {:id => core_time.to_param, :core_time => valid_attributes}, valid_session
        expect(response).to redirect_to(core_time)
      end
    end

    describe "with invalid params" do
      it "assigns the core_time as @core_time" do
        core_time = CoreTime.create! valid_attributes
        put :update, {:id => core_time.to_param, :core_time => invalid_attributes}, valid_session
        expect(assigns(:core_time)).to eq(core_time)
      end

      it "re-renders the 'edit' template" do
        core_time = CoreTime.create! valid_attributes
        put :update, {:id => core_time.to_param, :core_time => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested core_time" do
      core_time = CoreTime.create! valid_attributes
      expect {
        delete :destroy, {:id => core_time.to_param}, valid_session
      }.to change(CoreTime, :count).by(-1)
    end

    it "redirects to the core_times list" do
      core_time = CoreTime.create! valid_attributes
      delete :destroy, {:id => core_time.to_param}, valid_session
      expect(response).to redirect_to(core_times_url)
    end
  end

end