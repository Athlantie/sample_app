require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before(:each) {
    sign_in user
    visit root_path
  }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do

        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end

  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe "micropost pagination" do

    let(:user) { FactoryGirl.create(:user) }
    before do
      31.times { FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum") }
      sign_in user
      visit root_path
    end

    it { should have_selector('div.pagination') }

    it "should list each micropost" do
      Micropost.paginate(page: 1).each do |micropost|
        expect(page).to have_selector('li', text: micropost.content)
      end
    end
  end


  describe "micropost delete links" do

    it { should_not have_link('delete') }
    describe "as another user" do
      let(:user1) { FactoryGirl.create(:user) }
      let!(:m) { FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum") }
      let!(:m1) { FactoryGirl.create(:micropost, user: user1, content: "Lorem ipsum 1") }
      before do
        sign_in user1
        visit root_path
      end

      it { should have_link('delete', href: micropost_path(m1)) }
      it { should_not have_link('delete', href: micropost_path(m)) }
    end
  end

end
