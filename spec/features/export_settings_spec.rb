# frozen_string_literal: true

describe 'Export settings as instance-level access methods' do
  let(:config) do
    Qonfig::DataSet.build do
      setting :credentials do
        setting :login, '0exp'
        setting :password, 'test123'
      end

      setting :queue do
        setting :adapter, :sidekiq
        setting :threads, 10
      end
    end
  end

  specify 'default values => do nothing' do
    my_simple_object = Object.new
    config.export_settings(my_simple_object) # do nothing :D

    expect(my_simple_object).not_to respond_to(:credentials)
    expect(my_simple_object).not_to respond_to(:login)
    expect(my_simple_object).not_to respond_to(:queue)
    expect(my_simple_object).not_to respond_to(:adaper)
    expect(my_simple_object).not_to respond_to(:threads)
  end

  specify '<non-raw export> (concrete keys as values and keys with nestings as a hash)' do
    my_simple_object = Object.new

    config.export_settings(
      my_simple_object,
      'credentials',
      mappings: { adapter: 'queue.adapter' },
      prefix: 'config_'
    )

    expect(my_simple_object).to respond_to(:config_credentials) # NOTE: hash
    expect(my_simple_object).to respond_to(:config_adapter) # NOTE: value
    expect(my_simple_object.config_credentials).to be_a(Hash)

    expect(my_simple_object.config_credentials).to match('login' => '0exp', 'password' => 'test123')
    expect(my_simple_object.config_adapter).to eq(:sidekiq)
  end

  specify '<raw export> (concrete keys as values and keys with nestings as Qonfig::Settings)' do
    my_simple_object = Object.new

    config.export_settings(
      my_simple_object,
      'credentials',
      mappings: { adapter: 'queue.adapter' },
      prefix: 'kek_',
      raw: true
    )

    expect(my_simple_object).to respond_to(:kek_credentials) # NOTE: Qonfig::Settings
    expect(my_simple_object).to respond_to(:kek_adapter) # NOTE: value
    expect(my_simple_object.kek_credentials).to be_a(Qonfig::Settings)

    expect(my_simple_object.kek_credentials.login).to eq('0exp')
    expect(my_simple_object.kek_credentials.password).to eq('test123')
    expect(my_simple_object.kek_adapter).to eq(:sidekiq)
  end

  specify '(PRIVATE API) attr_writers (config muatators)' do
    my_simple_object = Object.new

    config.export_settings(
      my_simple_object,
      'credentials.login', 'credentials',
      mappings: { driver: 'queue.adapter' },
      accessor: true
    )

    # NOTE: you can mutate config settings via exported attr_writers
    my_simple_object.login = 'D@iVeR'
    my_simple_object.driver = :delayed_job

    # NOTE: check taht original config was changed
    expect(config.settings.credentials.login).to eq('D@iVeR')
    expect(config.settings.queue.adapter).to eq(:delayed_job)

    # NOTE: check that reder returns new value
    expect(my_simple_object.login).to eq('D@iVeR')
    expect(my_simple_object.driver).to eq(:delayed_job)

    # NOTE: some mutators can be ambiguous - be careful :thinking:
    expect { my_simple_object.credentials = 123 }.to raise_error(Qonfig::AmbiguousSettingValueError)
  end
end
