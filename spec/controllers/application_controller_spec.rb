# Copyright 2011-2017, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
# 
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

require 'rails_helper'

describe ApplicationController do
  controller do
    def create
      render nothing: true
    end

    def show
      raise Ldp::Gone
    end
  end

  context "normal auth" do
    it "should check for authenticity token" do
      expect(controller).to receive(:verify_authenticity_token)
      post :create
    end
  end
  context "ingest API" do
    before do
      ApiToken.create token: 'secret_token', username: 'archivist1@example.com', email: 'archivist1@example.com'
    end
    it "should not check for authenticity token for API requests" do
      request.headers['Avalon-Api-Key'] = 'secret_token'
      expect(controller).not_to receive(:verify_authenticity_token)
      post :create
    end
  end

  describe '#get_user_collections' do
    let(:collection1) { FactoryGirl.create(:collection) }
    let(:collection2) { FactoryGirl.create(:collection) }

    it 'returns all collections for an administrator' do
      login_as :administrator
      expect(controller.get_user_collections).to include(collection1)
      expect(controller.get_user_collections).to include(collection2)
    end
    it 'returns only relevant collections for a manager' do
      login_user collection1.managers.first
      expect(controller.get_user_collections).to include(collection1)
      expect(controller.get_user_collections).not_to include(collection2)
    end
    it 'returns no collections for an end-user' do
      login_as :user
      expect(controller.get_user_collections).to be_empty
    end
  end
  
  describe "exceptions handling" do
    it "renders deleted_pid template" do
      get :show, id: 'deleted-id'
      expect(response).to render_template("errors/deleted_pid")
    end
  end
end
