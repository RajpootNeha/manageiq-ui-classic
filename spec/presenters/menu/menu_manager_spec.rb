describe Menu::Manager do
  include Spec::Support::MenuHelper

  before do
    Singleton.__init__(Menu::YamlLoader)
    Singleton.__init__(Menu::Manager)
  end

  context "initialize" do
    it "loads default menu items" do
      section = Menu::Manager.section(:vi)
      expect(section).to be_truthy
      expect(section.items[0].id).to eq('dashboard')
    end

    it "loads custom menu items" do
      expect(Menu::YamlLoader).to receive(:load).and_call_original
      Menu::Manager.menu {}
    end
  end

  context "menu" do
    it "knows about custom section with items" do
      temp_file  = section_file
      temp_file2 = item_file
      begin
        expect(Dir).to receive(:glob).and_return([temp_file2.path, temp_file.path])

        section = nil
        Menu::Manager.menu do |a_section|
          section = a_section if a_section.name == 'Red Hat'
        end
        expect(section).to be_truthy
        expect(section.items.first).to be_truthy
      ensure
        temp_file.unlink
        temp_file2.unlink
      end
    end
  end

  context "menu" do
    it "knows about custom items from settings" do
      ::Settings.ui.custom_menu = settings_custom_items
      count = 0
      Menu::Manager.menu do |item|
        count += 1 if item.kind_of?(Menu::Item) && item.name =~ /^Custom Item/
      end
      expect(count).to eq(2)
    end
  end
end
