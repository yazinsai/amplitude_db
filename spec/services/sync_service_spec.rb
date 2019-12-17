require 'rails_helper'

RSpec.describe SyncService do
  describe SyncService::Extractor do
    let(:zipped_data) { File.read('spec/spec_data/archive.zip') }
    let(:extractor) { SyncService::Extractor.new(zipped_data) }

    describe '#extract_zip' do
      after { FileUtils.rm_rf(Dir["download/*"]) }

      it 'extract files from archive to default path' do
        extractor.extract_zip
        expect(Dir["download/*"]).to eq ["download/second.json.gz", "download/first.json.gz"]
      end
    end

    describe '#extract_gz' do      
      # 252120_2019-12-11_10#912.json.gz in spec/spec_data folder contains 6 lines that are json objects
      it 'extract properly' do
        data = extractor.extract_gz(Dir["spec/spec_data/*.gz"])
        expect(data.count).to eq 6
      end
    end
  end

  describe 'models creation' do
    let(:params_ary) { JSON.parse(File.read('spec/spec_data/test1.json')) }
    let(:modeler) { SyncService::Modeler.new(params_ary) }

    describe 'user creation' do
      describe 'when user with passed device_id exists' do      
        let!(:passed_device_id) { 'fds321dsa5' }
        let!(:user) { User.create(amplitude_user_id: '243432123') }
        let!(:device) { Device.create(device_id: passed_device_id, user: user) }        

        describe 'when only device_id is passed' do
          it 'return existed user' do
            expect(modeler.create_user(passed_device_id)).to eq user
          end
        end

        describe 'when user_id is also passed' do
          describe 'when existed user has numeric amplitude_user_id' do
            let(:passed_amals_user_id) { '7ADFDdfd165fsdf5' }

            it 'return existed user with updated amplitude_user_id' do
              created_user = modeler.create_user(passed_device_id, passed_amals_user_id)
              expect(created_user).to eq user
              expect(created_user.amplitude_user_id).to eq passed_amals_user_id
            end
          end
        end

        describe 'when user_properties is also passed' do
          let(:user_properites) { { 'email' => 'test@gmail.com', 'ref' => 'default' } }

          it 'return existed user with updated email and ref' do
            created_user = modeler.create_user(passed_device_id, nil, user_properites)
            expect(created_user).to eq user
            expect(created_user.email).to eq user_properites['email']
            expect(created_user.ref).to eq user_properites['ref']
          end
        end
      end

      describe 'when user with passed user_id exists' do
        let!(:passed_user_id) { 'ghghdas321dsa5' }
        let!(:user) { User.create(amplitude_user_id: 'ghghdas321dsa5') }

        it 'return existed user' do
          expect(modeler.create_user('some_device_id', passed_user_id)).to eq user
        end
      end

      describe 'when there is no match by passed params' do
        let!(:passed_user_id) { 'ghghdas321dsa5' }

        it 'return new user created by passed user_id' do
          new_user = modeler.create_user('some_device_id', passed_user_id)
          expect(new_user.amplitude_user_id).to eq passed_user_id
        end

        it 'return nil if user_id was not passed' do
          expect(modeler.create_user('some_device_id')).to eq nil
        end
      end      
    end

    describe 'device creation' do
      let!(:passed_device_id) { 'fds321dsa5' }

      describe 'when device with passed device_id exists' do
        let!(:device) { Device.create(device_id: passed_device_id) }

        it 'return existed device' do
          new_device = modeler.create_device({'device_id' => passed_device_id})
          expect(new_device).to eq device
        end
      end

      describe 'when device with passed device_id does not exist' do
        it 'return new device created by passed device_id' do
          new_device = modeler.create_device({'device_id' => passed_device_id})
          expect(new_device.device_id).to eq passed_device_id
        end
      end

      describe 'when user is passed' do
        let!(:user) { User.create(amplitude_user_id: '243432123') }
        let!(:device) { Device.create(device_id: passed_device_id, user: user) }

        it "assign passed user to device if it hasn't one" do
          new_device = modeler.create_device({'device_id' => 'passed_device_id'}, user)
          expect(new_device.user).to eq user
        end

        it "do not assign passed user to device if it has one" do
          new_device = modeler.create_device({'device_id' => passed_device_id}, user)
          expect(new_device.user).to eq user
        end
      end

      describe 'updating fields' do
        let!(:params) do
          {
            'device_id' => passed_device_id,
            'device_type' => 'type',
            'device_family' => 'family',
            'device_model' => 'model'
          }        
        end
        let!(:device_with_empty_fields) do
          Device.create(
            'device_id' => passed_device_id, 'device_type' => nil,
            'device_family' => 'ABC', 'device_model' => nil)
        end

        it 'update each field unless it was not setted' do
          new_device = modeler.create_device(params)
          expect(new_device).to eq device_with_empty_fields
          expect(new_device.device_type).to eq params['device_type']
          expect(new_device.device_family).to eq device_with_empty_fields.device_family
          expect(new_device.device_model).to eq params['device_model']
        end
      end
    end
  end
end
