require 'rails_helper'
require_relative '__version__'

RSpec.shared_examples 'the given occurrence is not valid' do ||
  it 'responds with 422' do
    is_expected.to respond_with 422
  end

  it 'does not add any occurrence' do
    expect(Occurrence.count).to eq 0
  end

  it 'does not returns anything in the body' do
    expect(response.body).to be_empty
  end
end

RSpec.shared_examples 'the given occurrence is valid' do ||
  it 'responds with 201' do
    is_expected.to respond_with 201
  end

  it 'adds the occurrence in the database' do
    expect(Occurrence.count).to eq 1
  end

  it 'returns a JSON' do
    expect(response.body).to be_instance_of(String)
  end

  describe 'the response' do
    subject { JSON.parse(response.body) }

    it 'contains the occurrence that has been saved' do
      expect(subject['symptom_id']).to eq @valid_occurrence.symptom_id
      expect(Time.zone.parse(subject['date'])).to be_within(1.second).of @valid_occurrence.date
    end

    it 'contains the generated ID' do
      expect(subject['id']).not_to be_nil
    end

    it 'is associated to the logged in user' do
      expect(subject['user_id']).to eq @user.id
    end
  end
end

RSpec.shared_examples 'no error occurs and the key occurrences is present' do ||
  it 'responds with 200' do
    is_expected.to respond_with 200
  end

  it 'returns a JSON containing the key "occurrences"' do
    expect(response.body).to be_instance_of(String)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response).to have_key('occurrences')
  end
end

RSpec.shared_examples 'status 422 and one occurrence' do
  it 'responds with status 422' do
    is_expected.to respond_with 422
  end

  it 'does not delete the occurrence' do
    expect(Occurrence.count).to eq 1
  end
end

RSpec.describe  V1::OccurrencesController, type: :controller do
  describe '#create' do
    it { should route(:post, @version + '/occurrences').to(action: :create) }
    it_behaves_like 'POST protected with authentication controller', :create, occurrence: @valid_occurrence.to_json

    context 'with valid authentication headers' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when a valid, basic (no gps_location, no factors) occurrence is given' do
        before(:each) do
          @valid_occurrence = build(:occurrence)
          post :create, occurrence: @valid_occurrence.to_json
        end

        include_examples 'the given occurrence is valid'
      end

      context 'when no occurrence is given' do
        before(:each) do
          post :create
        end

        include_examples 'the given occurrence is not valid'
      end

      context 'when the given occurrence references a non existing symptom' do
        before(:each) do
          @occurrence = build(:occurrence_with_non_existing_symptom)
          post :create, occurrence: @occurrence.to_json
        end

        include_examples 'the given occurrence is not valid'
      end

      context 'when a valid occurrence with gps_location is given' do
        before(:each) do
          @valid_occurrence = build(:occurrence_with_gps_coordinates)
          post :create, occurrence: @valid_occurrence.to_json(include: :gps_coordinate)
        end

        include_examples 'the given occurrence is valid'

        it 'adds the gps_coordinate in the database' do
          expect(GpsCoordinate.count).to eq 1
        end

        describe 'the response' do
          subject { JSON.parse(response.body) }

          it 'contains the occurrence that has been saved including the gps_coordinate' do
            expect(subject['gps_coordinate']).not_to be_nil
            expect(subject['gps_coordinate']['latitude']).to eq @valid_occurrence.gps_coordinate.latitude
            expect(subject['gps_coordinate']['longitude']).to eq @valid_occurrence.gps_coordinate.longitude
            expect(subject['gps_coordinate']['altitude']).to eq @valid_occurrence.gps_coordinate.altitude
          end

          it 'contains the generated ID of gps_coordinate' do
            expect(subject['gps_coordinate']['id']).not_to be_nil
          end
        end
      end
    end
  end

  describe '#index' do
    it { should route(:get, @version + '/occurrences').to(action: :index) }

    context 'when no user is logged in' do
      it_behaves_like 'GET protected with authentication controller', :create
    end

    context 'with valid authentication headers' do

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end


      context 'when the user has not added an occurrence' do

        before(:each) do
          get :index
        end

        include_examples 'no error occurs and the key occurrences is present'

        it 'returns no occurrence' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['occurrences'].length).to eq 0
        end

      end

      context 'when the user has added an occurrence' do

        before(:each) do
          @valid_occurrence = create(:occurrence, user_id: @user.id)
        end

        before(:each) do
          get :index
        end

        include_examples 'no error occurs and the key occurrences is present'

        it 'returns one occurrence' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['occurrences'].length).to eq 1
        end

        it 'returns one occurrence with its symptom' do
          subject = JSON.parse(response.body)['occurrences']
          subject.each do |occurrence|
            expect(occurrence).to have_key 'symptom'
          end
        end
      end

      context 'when the user has added ten occurrences' do

        before(:each) do
          @valid_occurrence = create_list(:occurrence, 10, user_id: @user.id)
        end

        before(:each) do
          get :index
        end

        include_examples 'no error occurs and the key occurrences is present'

        it 'returns ten occurrences' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['occurrences'].length).to eq 10
        end

        context 'when an other user added also ten occurrences' do

          before(:each) do
            @valid_occurrence = create_list(:occurrence, 10)
          end

          before(:each) do
            get :index
          end

          it 'returns ten occurrences' do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response['occurrences'].length).to eq 10
          end

        end

      end

    end
  end
  describe '#destroy' do
    it { should route(:delete, @version + '/occurrences').to(action: :destroy) }

    context 'when no user is logged in' do
      it_behaves_like 'DELETE protected with authentication controller', :destroy
    end

    context 'when an user is logged in' do

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when the occurrence is in the database'do
        before(:each) do
          @valid_occurrence = create(:occurrence, user_id: @user.id)
        end

        context 'when the occurrence id is valid' do
          before(:each) do
            delete :destroy, occurrence_id: @valid_occurrence.id
          end

          it 'responds with status 200' do
            is_expected.to respond_with 200
          end

          it 'deletes the occurrence' do
            expect(Occurrence.count).to eq 0
          end

          it 'returns the destroy object' do
            expect(JSON.parse(response.body)['user_id']).to eq @user.id
            expect(JSON.parse(response.body)['id']).to eq @valid_occurrence.id
          end
        end

        context 'when the given occurrence id is not valid or' do
          before(:each) do
            delete :destroy, symptom_id: -1
          end

          include_examples 'status 422 and one occurrence'


        end
      end


    end

  end
  describe '#get_weather_information' do
    expected_json = {"response"=>{"version"=>"0.1", "termsofService"=>"http://www.wunderground.com/weather/api/d/terms.html", "features"=>{"history"=>1}}, "history"=>{"date"=>{"pretty"=>"March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"March 23, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"23", "hour"=>"23", "min"=>"00", "tzname"=>"UTC"}, "observations"=>[{"date"=>{"pretty"=>"12:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"11:00 PM GMT on March 23, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"23", "hour"=>"23", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"8", "tempi"=>"46", "dewptm"=>"4", "dewpti"=>"39", "hum"=>"70", "wspdm"=>"14.4", "wspdi"=>"8.9", "wgustm"=>"", "wgusti"=>"", "wdird"=>"50", "wdire"=>"NE", "vism"=>"14", "visi"=>"9", "pressurem"=>"1021", "pressurei"=>"30.14", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Overcast", "icon"=>"cloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 23231 06458 45964 /0504 10080 20041 30070 40207 51027 333 88/62 91108 91206"}, {"date"=>{"pretty"=>"12:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"11:25 PM GMT on March 23, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"23", "hour"=>"23", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"8.0", "tempi"=>"46.4", "dewptm"=>"4.0", "dewpti"=>"39.2", "hum"=>"76", "wspdm"=>"14.8", "wspdi"=>"9.2", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"10.0", "visi"=>"6.2", "pressurem"=>"1021", "pressurei"=>"30.15", "windchillm"=>"5.5", "windchilli"=>"41.9", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 232325Z AUTO 06008KT 9999 BKN120/// 08/04 Q1021 BLU"}, {"date"=>{"pretty"=>"12:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"11:55 PM GMT on March 23, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"23", "hour"=>"23", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"8.0", "tempi"=>"46.4", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"81", "wspdm"=>"11.1", "wspdi"=>"6.9", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"9.0", "visi"=>"5.6", "pressurem"=>"1021", "pressurei"=>"30.15", "windchillm"=>"6.1", "windchilli"=>"42.9", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Overcast", "icon"=>"cloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 232355Z AUTO 06006KT 9000 SCT110/// OVC130/// 08/05 Q1021 BLU"}, {"date"=>{"pretty"=>"1:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"01", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"12:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"8", "tempi"=>"46", "dewptm"=>"4", "dewpti"=>"40", "hum"=>"73", "wspdm"=>"10.8", "wspdi"=>"6.7", "wgustm"=>"", "wgusti"=>"", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"9", "visi"=>"6", "pressurem"=>"1022", "pressurei"=>"30.19", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Partly Cloudy", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24001 06458 35959 /0603 10076 20045 30082 40222 51032 333 83/61 88/63 91109 91206 555 10145 20020"}, {"date"=>{"pretty"=>"1:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"01", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"12:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"7.0", "tempi"=>"44.6", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"87", "wspdm"=>"16.7", "wspdi"=>"10.4", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"50", "wdire"=>"NE", "vism"=>"7.0", "visi"=>"4.3", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"4.0", "windchilli"=>"39.2", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240025Z AUTO 05009KT 7000 FEW100/// SCT120/// BKN220/// 07/05 Q1022 WHT"}, {"date"=>{"pretty"=>"1:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"01", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"12:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"7.0", "tempi"=>"44.6", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"87", "wspdm"=>"14.8", "wspdi"=>"9.2", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"50", "wdire"=>"NE", "vism"=>"7.0", "visi"=>"4.3", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"4.3", "windchilli"=>"39.7", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240055Z AUTO 05008KT 7000 BKN210/// 07/05 Q1022 WHT"}, {"date"=>{"pretty"=>"2:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"1:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"01", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"7", "tempi"=>"44", "dewptm"=>"4", "dewpti"=>"40", "hum"=>"81", "wspdm"=>"14.4", "wspdi"=>"8.9", "wgustm"=>"", "wgusti"=>"", "wdird"=>"50", "wdire"=>"NE", "vism"=>"7", "visi"=>"4", "pressurem"=>"1023", "pressurei"=>"30.20", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24011 06458 45957 /0504 10067 20045 30087 40226 51025 333 87/71 91105 91204"}, {"date"=>{"pretty"=>"2:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"1:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"01", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"7.0", "tempi"=>"44.6", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"87", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"40", "wdire"=>"NE", "vism"=>"6.0", "visi"=>"3.7", "pressurem"=>"1021", "pressurei"=>"30.15", "windchillm"=>"3.8", "windchilli"=>"38.8", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240125Z AUTO 04010KT 6000 BKN200/// 07/05 Q1021 WHT"}, {"date"=>{"pretty"=>"2:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"1:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"01", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"50", "wdire"=>"NE", "vism"=>"-9999.0", "visi"=>"-9999.0", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.5", "windchilli"=>"36.6", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240155Z AUTO 05010KT 4900 BKN190/// 06/05 Q1022 GRN"}, {"date"=>{"pretty"=>"3:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"2:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"6", "tempi"=>"44", "dewptm"=>"5", "dewpti"=>"40", "hum"=>"83", "wspdm"=>"18.0", "wspdi"=>"11.2", "wgustm"=>"", "wgusti"=>"", "wdird"=>"50", "wdire"=>"NE", "vism"=>"4.9", "visi"=>"3", "pressurem"=>"1023", "pressurei"=>"30.20", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24021 06458 45949 /0505 10064 20047 30087 40226 51016 333 87/69 91108 91206"}, {"date"=>{"pretty"=>"3:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"2:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"4.5", "visi"=>"2.8", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.5", "windchilli"=>"36.6", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240225Z AUTO 07010KT 4500 BR BKN200/// 06/05 Q1022 GRN"}, {"date"=>{"pretty"=>"3:49 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"49", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"2:49 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"49", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"16.7", "wspdi"=>"10.4", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"-9999.0", "visi"=>"-9999.0", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.8", "windchilli"=>"37.0", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Partly Cloudy", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"SPECI EBBE 240249Z AUTO 07009KT 3600 BR FEW200/// 06/05 Q1022 YLO"}, {"date"=>{"pretty"=>"3:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"2:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"02", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"-9999.0", "visi"=>"-9999.0", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.5", "windchilli"=>"36.6", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Partly Cloudy", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240255Z AUTO 07010KT 3800 BR FEW220/// 06/05 Q1022 GRN"}, {"date"=>{"pretty"=>"4:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"3:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"6", "tempi"=>"42", "dewptm"=>"5", "dewpti"=>"40", "hum"=>"92", "wspdm"=>"18.0", "wspdi"=>"11.2", "wgustm"=>"", "wgusti"=>"", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"3.8", "visi"=>"2", "pressurem"=>"1023", "pressurei"=>"30.21", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24031 06458 47938 /0705 10058 20047 30088 40228 53006 71000 333 81/72 91108 91206"}, {"date"=>{"pretty"=>"4:03 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"03", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"3:03 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"03", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"-9999.0", "visi"=>"-9999.0", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.5", "windchilli"=>"36.6", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"SPECI EBBE 240303Z AUTO 06010KT 3600 BR NCD 06/05 Q1022 YLO"}, {"date"=>{"pretty"=>"4:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"3:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"16.7", "wspdi"=>"10.4", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"-9999.0", "visi"=>"-9999.0", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.8", "windchilli"=>"37.0", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240325Z AUTO 06009KT 3600 BR NCD 06/05 Q1022 YLO"}, {"date"=>{"pretty"=>"4:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"3:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"03", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.5", "windchilli"=>"36.6", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Partly Cloudy", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240355Z AUTO 06010KT 3000 BR FEW230/// 06/05 Q1022 YLO"}, {"date"=>{"pretty"=>"5:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"4:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"6", "tempi"=>"42", "dewptm"=>"5", "dewpti"=>"40", "hum"=>"91", "wspdm"=>"18.0", "wspdi"=>"11.2", "wgustm"=>"", "wgusti"=>"", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"2", "pressurem"=>"1023", "pressurei"=>"30.22", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24041 06458 47930 /0605 10055 20046 30091 40232 53005 71000 333 81/73 91107 91206"}, {"date"=>{"pretty"=>"5:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"4:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"5.0", "tempi"=>"41.0", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"100", "wspdm"=>"16.7", "wspdi"=>"10.4", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"2.9", "visi"=>"1.8", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"1.5", "windchilli"=>"34.7", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240425Z AUTO 07009KT 2900 BR NCD 05/05 Q1022 YLO"}, {"date"=>{"pretty"=>"5:52 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"52", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"4:52 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"52", "tzname"=>"UTC"}, "tempm"=>"5.0", "tempi"=>"41.0", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"100", "wspdm"=>"13.0", "wspdi"=>"8.1", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"2.1", "windchilli"=>"35.8", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"SPECI EBBE 240452Z 06007KT 3000 BR BKN240 05/05 Q1022 YLO YLO"}, {"date"=>{"pretty"=>"5:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"4:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"04", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"14.8", "wspdi"=>"9.2", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"3.0", "windchilli"=>"37.5", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240455Z 06008KT 3000 BR BKN240 06/05 Q1022 YLO YLO"}, {"date"=>{"pretty"=>"6:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"5:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"6", "tempi"=>"42", "dewptm"=>"5", "dewpti"=>"40", "hum"=>"91", "wspdm"=>"14.4", "wspdi"=>"8.9", "wgustm"=>"", "wgusti"=>"", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"2", "pressurem"=>"1023", "pressurei"=>"30.22", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24051 06458 41930 50604 10055 20046 30091 40231 50003 71022 80002 333 85074 91107 91205"}, {"date"=>{"pretty"=>"6:23 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"23", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"5:23 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"23", "tzname"=>"UTC"}, "tempm"=>"5.0", "tempi"=>"41.0", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"100", "wspdm"=>"18.5", "wspdi"=>"11.5", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"1.3", "windchilli"=>"34.3", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Scattered Clouds", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"SPECI EBBE 240523Z 06010KT 3000 BR FEW006 SCT220 05/05 Q1022 YLO GRN TEMPO YLO"}, {"date"=>{"pretty"=>"6:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"5:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"5.0", "tempi"=>"41.0", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"100", "wspdm"=>"20.4", "wspdi"=>"12.7", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1022", "pressurei"=>"30.18", "windchillm"=>"1.0", "windchilli"=>"33.9", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Scattered Clouds", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240525Z 06011KT 3000 BR FEW006 SCT220 05/05 Q1022 YLO GRN TEMPO YLO"}, {"date"=>{"pretty"=>"6:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"5:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"05", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"5.0", "tempi"=>"41.0", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"100", "wspdm"=>"13.0", "wspdi"=>"8.1", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1023", "pressurei"=>"30.21", "windchillm"=>"2.1", "windchilli"=>"35.8", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Scattered Clouds", "icon"=>"partlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240555Z 07007KT 3000 BR FEW006 SCT220 05/05 Q1023 YLO GRN TEMPO YLO"}, {"date"=>{"pretty"=>"7:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"6:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"5", "tempi"=>"42", "dewptm"=>"4", "dewpti"=>"40", "hum"=>"90", "wspdm"=>"10.8", "wspdi"=>"6.7", "wgustm"=>"", "wgusti"=>"", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"2", "pressurem"=>"1024", "pressurei"=>"30.24", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24061 06458 31330 50703 10053 20045 30101 40240 53010 71022 82602 333 20052 30004 82706 83072 91108 91206"}, {"date"=>{"pretty"=>"7:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"6:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"11.1", "wspdi"=>"6.9", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"70", "wdire"=>"ENE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1024", "pressurei"=>"30.24", "windchillm"=>"3.7", "windchilli"=>"38.6", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240625Z 07006KT 3000 BR FEW006 BKN200 06/05 Q1024 YLO GRN TEMPO YLO"}, {"date"=>{"pretty"=>"7:52 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"52", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"6:52 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"52", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"16.7", "wspdi"=>"10.4", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"30", "wdire"=>"NNE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1024", "pressurei"=>"30.24", "windchillm"=>"2.8", "windchilli"=>"37.0", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"SPECI EBBE 240652Z 03009KT 3000 BR FEW006 BKN200 06/05 Q1024 YLO YLO BECMG GRN"}, {"date"=>{"pretty"=>"7:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"6:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"06", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"14.8", "wspdi"=>"9.2", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"30", "wdire"=>"NNE", "vism"=>"3.0", "visi"=>"1.9", "pressurem"=>"1025", "pressurei"=>"30.27", "windchillm"=>"3.0", "windchilli"=>"37.5", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240655Z 03008KT 3000 BR FEW006 BKN200 06/05 Q1025 YLO YLO BECMG GRN"}, {"date"=>{"pretty"=>"8:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"08", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"7:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"6", "tempi"=>"42", "dewptm"=>"5", "dewpti"=>"40", "hum"=>"92", "wspdm"=>"14.4", "wspdi"=>"8.9", "wgustm"=>"", "wgusti"=>"", "wdird"=>"30", "wdire"=>"NNE", "vism"=>"3.0", "visi"=>"2", "pressurem"=>"1026", "pressurei"=>"30.29", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24071 06458 41330 50304 10055 20047 30113 40255 53022 71022 82602 333 82706 85070 91106 91204"}, {"date"=>{"pretty"=>"8:25 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"08", "min"=>"25", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"7:25 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"25", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"16.7", "wspdi"=>"10.4", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"60", "wdire"=>"ENE", "vism"=>"-9999.0", "visi"=>"-9999.0", "pressurem"=>"1025", "pressurei"=>"30.27", "windchillm"=>"2.8", "windchilli"=>"37.0", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240725Z 06009KT 3200 BR SCT006 BKN200 06/05 Q1025 YLO YLO BECMG GRN"}, {"date"=>{"pretty"=>"8:55 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"08", "min"=>"55", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"7:55 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"07", "min"=>"55", "tzname"=>"UTC"}, "tempm"=>"6.0", "tempi"=>"42.8", "dewptm"=>"5.0", "dewpti"=>"41.0", "hum"=>"93", "wspdm"=>"22.2", "wspdi"=>"13.8", "wgustm"=>"-9999.0", "wgusti"=>"-9999.0", "wdird"=>"50", "wdire"=>"NE", "vism"=>"3.5", "visi"=>"2.2", "pressurem"=>"1026", "pressurei"=>"30.30", "windchillm"=>"2.1", "windchilli"=>"35.8", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"-9999.00", "precipi"=>"-9999.00", "conds"=>"Mostly Cloudy", "icon"=>"mostlycloudy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"METAR EBBE 240755Z 05012KT 3500 BR SCT006 BKN200 06/05 Q1026 YLO YLO BECMG GRN"}, {"date"=>{"pretty"=>"9:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"09", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"8:00 AM GMT on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"08", "min"=>"00", "tzname"=>"UTC"}, "tempm"=>"6", "tempi"=>"43", "dewptm"=>"5", "dewpti"=>"41", "hum"=>"90", "wspdm"=>"21.6", "wspdi"=>"13.4", "wgustm"=>"", "wgusti"=>"", "wdird"=>"50", "wdire"=>"NE", "vism"=>"3.5", "visi"=>"2", "pressurem"=>"1026", "pressurei"=>"30.31", "windchillm"=>"-999", "windchilli"=>"-999", "heatindexm"=>"-9999", "heatindexi"=>"-9999", "precipm"=>"", "precipi"=>"", "conds"=>"Mist", "icon"=>"hazy", "fog"=>"0", "rain"=>"0", "snow"=>"0", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "metar"=>"AAXX 24081 06458 41335 70506 10060 20050 30122 40262 51031 71022 84602 333 84706 87070 91108 91206"}], "dailysummary"=>[{"date"=>{"pretty"=>"12:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"00", "tzname"=>"Europe/Brussels"}, "fog"=>"0", "rain"=>"0", "snow"=>"0", "snowfallm"=>"", "snowfalli"=>"", "monthtodatesnowfallm"=>"", "monthtodatesnowfalli"=>"", "since1julsnowfallm"=>"", "since1julsnowfalli"=>"", "snowdepthm"=>"", "snowdepthi"=>"", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "meantempm"=>"6", "meantempi"=>"44", "meandewptm"=>"5", "meandewpti"=>"41", "meanpressurem"=>"1022.79", "meanpressurei"=>"30.20", "meanwindspdm"=>"14", "meanwindspdi"=>"9", "meanwdire"=>"ENE", "meanwdird"=>"57", "meanvism"=>"4.9", "meanvisi"=>"3.0", "humidity"=>"90", "maxtempm"=>"8", "maxtempi"=>"46", "mintempm"=>"5", "mintempi"=>"41", "maxhumidity"=>"100", "minhumidity"=>"70", "maxdewptm"=>"5", "maxdewpti"=>"41", "mindewptm"=>"4", "mindewpti"=>"39", "maxpressurem"=>"1026", "maxpressurei"=>"30.31", "minpressurem"=>"1021", "minpressurei"=>"30.14", "maxwspdm"=>"22", "maxwspdi"=>"14", "minwspdm"=>"11", "minwspdi"=>"7", "maxvism"=>"14.0", "maxvisi"=>"9.0", "minvism"=>"2.9", "minvisi"=>"1.8", "gdegreedays"=>"0", "heatingdegreedays"=>"22", "coolingdegreedays"=>"0", "precipm"=>"0.0", "precipi"=>"0.00", "precipsource"=>"3Or6HourObs", "heatingdegreedaysnormal"=>"", "monthtodateheatingdegreedays"=>"", "monthtodateheatingdegreedaysnormal"=>"", "since1sepheatingdegreedays"=>"", "since1sepheatingdegreedaysnormal"=>"", "since1julheatingdegreedays"=>"", "since1julheatingdegreedaysnormal"=>"", "coolingdegreedaysnormal"=>"", "monthtodatecoolingdegreedays"=>"", "monthtodatecoolingdegreedaysnormal"=>"", "since1sepcoolingdegreedays"=>"", "since1sepcoolingdegreedaysnormal"=>"", "since1jancoolingdegreedays"=>"", "since1jancoolingdegreedaysnormal"=>""}]}}

    it 'calls w_api.history_for' do
      @w_api = double()
      V1::OccurrencesController.w_api = @w_api
      allow(@w_api).to receive(:history_for).and_return(expected_json)
      o = V1::OccurrencesController.new
      expect(@w_api).to receive(:history_for)
      o.get_weather_information(nil, nil, nil)
    end

  end
end
