require_relative "../../../base"

require Vagrant.source_root.join("plugins/provisioners/salt/provisioner")

describe VagrantPlugins::Salt::Provisioner do
  include_context "unit"

  subject { described_class.new(machine, config) }

  let(:iso_env) do
    # We have to create a Vagrantfile so there is a root path
    env = isolated_environment
    env.vagrantfile("")
    env.create_vagrant_env
  end

  let(:machine) { iso_env.machine(iso_env.machine_names[0], :dummy) }
  let(:config)       { double("config") }
  let(:communicator) { double("comm") }
  let(:guest)        { double("guest") }

  before do
    allow(machine).to receive(:communicate).and_return(communicator)
    allow(machine).to receive(:guest).and_return(guest)

    allow(communicator).to receive(:execute).and_return(true)
    allow(communicator).to receive(:upload).and_return(true)

    allow(guest).to receive(:capability?).and_return(false)
  end

  describe "#provision" do

  end

  describe "#call_highstate" do
    context "with masterless" do
      it "passes along extra cli flags" do
        allow(config).to receive(:run_highstate).and_return(true)
        allow(config).to receive(:verbose).and_return(true)
        allow(config).to receive(:masterless?).and_return(true)
        allow(config).to receive(:masterless).and_return(true)
        allow(config).to receive(:minion_id).and_return(nil)
        allow(config).to receive(:log_level).and_return(nil)
        allow(config).to receive(:colorize).and_return(false)
        allow(config).to receive(:pillar_data).and_return([])

        allow(config).to receive(:salt_call_args).and_return(["--output-dif"])
        allow(machine.communicate).to receive(:sudo)
        allow(machine.config.vm).to receive(:communicator).and_return(:notwinrm)
        allow(config).to receive(:install_master).and_return(false)

        expect(machine.communicate).to receive(:sudo).with("salt-call state.highstate --retcode-passthrough --local --log-level=debug --no-color --output-dif", {:error_key=>:ssh_bad_exit_status_muted})
        subject.call_highstate()
      end

      it "has no additional cli flags if not included" do
        allow(config).to receive(:run_highstate).and_return(true)
        allow(config).to receive(:verbose).and_return(true)
        allow(config).to receive(:masterless?).and_return(true)
        allow(config).to receive(:masterless).and_return(true)
        allow(config).to receive(:minion_id).and_return(nil)
        allow(config).to receive(:log_level).and_return(nil)
        allow(config).to receive(:colorize).and_return(false)
        allow(config).to receive(:pillar_data).and_return([])

        allow(config).to receive(:salt_call_args).and_return(nil)
        allow(machine.communicate).to receive(:sudo)
        allow(machine.config.vm).to receive(:communicator).and_return(:notwinrm)
        allow(config).to receive(:install_master).and_return(false)

        expect(machine.communicate).to receive(:sudo).with("salt-call state.highstate --retcode-passthrough --local --log-level=debug --no-color", {:error_key=>:ssh_bad_exit_status_muted})
        subject.call_highstate()
      end
    end
  end

end
