require 'test_helper'

class CallsControllerTest < ActionController::TestCase
    
  # Devise helpers
  include Devise::TestHelpers

  setup do
    @call = calls(:one)
    @user = users(:one)    
    @update = {
      :method_name => 'MyString3',
      :endpoint_uri => 'MyString3',
      :group_id => 1,
      :xml => 'MyText3',
      :method_type => 'POST'
    }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create call" do
    assert_difference('Call.count') do
      post :create, :call => @update
    end

    assert_redirected_to call_path(assigns(:call))
  end

  test "should show call" do
    call = Call.new(:method_name => "something", :group_id => 1, :endpoint_uri => "somewhere")
    call.build_group(:name => "group_name")
    call.save
    get :show, :id => call.to_param
    
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @call.to_param
    assert_response :success
  end

  test "should update call" do
    put :update, :id => @call.to_param, :call => @call.attributes
    assert_redirected_to call_path(assigns(:call))
  end

  test "should destroy call" do
    assert_difference('Call.count', -1) do
      delete :destroy, :id => @call.to_param
    end

    assert_redirected_to calls_path
  end
  
  test "should log the call if signed in" do
    sign_in @user
    call = Call.new(:method_name => "something", :group_id => 1, :endpoint_uri => "somewhere", :xml => "xml")
    call.save
    assert_difference('Log.count') do
      get :make_request, :id => call.to_param
    end
  end
  
  test "should not log the call if not signed in" do
    sign_out @user
    call = Call.new(:method_name => "something", :group_id => 1, :endpoint_uri => "somewhere", :xml => "xml")
    call.save
    assert_no_difference('Log.count') do
      get :make_request, :id => call.to_param
    end
  end


##  Test recent_group_id
#  test "should show recent group if signed in and recent_group_id set, no tab selected" do
#    sign_in users(:one)
#    @tab = Group.find(users(:one).recent_group_id).name
#    get :index
#    assert_tag(:tag => 'li', :content => "#{@tab}", :attributes => {:class => 'active_tab'})
#    sign_out users(:one)
#  end

#  test "should show selected tab if signed in and recent_group_id set, but tab IS selected" do
#    sign_in users(:one)
#    @tab = "MyString" # this must *not* be users(:one)'s recent_group_id
#    get :index, :tab => @tab
#    assert_tag(:tag => 'li', :content => "#{@tab}", :attributes => {:class => 'active_tab'})
#    sign_out users(:one)
#  end

#  test "should show all tab if signed in and recent_group_id NOT set, no tab selected" do
#    sign_in users(:two)
#    # recent_group_id should not be assigned for user :two in the fixture, therefore nil
#    get :index
#    assert_tag(:tag => 'li', :content => 'all', :attributes => {:class => 'active_tab'})
#    sign_out users(:two)
#  end

#  test "should show the all tab if user not signed in" do
#    get :index
#    assert_tag(:tag => 'li', :content => 'all', :attributes => {:class => 'active_tab'})
#  end
#  
#  test "should show the selected tab if user not signed in, but tab IS selected" do
#    @tab = "MyString"
#    get :index, :tab => "#{@tab}"
#    assert_tag(:tag => 'li', :content => "#{@tab}", :attributes => {:class => 'active_tab'})
#  end

#  test "should show all tab if signed in and recent_group_id set, all tab selected" do
#    sign_in users(:one)
#    @tab = "all"
#    get :index, :tab => "#{@tab}"
#    assert_tag(:tag => 'li', :content => "#{@tab}", :attributes => {:class => 'active_tab'})
#    sign_out users(:one)
#  end

#  test 'should update user.recent_group_id when new tab selected' do
#    @user = users(:one)
#    sign_in @user
#    @current_tab = Group.find(@user.recent_group_id).name
#    
#    puts "current_tab = #{@current_tab}, id #{@user.recent_group_id}"
#    
#    get :index, :tab => "all" # this should set the new recent_group_id
#    
#    puts "\nnow getting index without the tab".yellow
#    
#    get :index
#    
#    puts "index with :tab => all called, @user.recent_group_id: #{@user.recent_group_id}"
#    
#    assert(@current_tab != Group.find(@user.recent_group_id).name)
#  end
# 
#  test 'should show the right tab when new tab selected' do
#    @user = users(:one)
#    sign_in @user
#    @current_tab = Group.find(@user.recent_group_id).name
#    
#    puts "current_tab = #{@current_tab}, id #{@user.recent_group_id}"
#    
#    get :index, :tab => groups(:one).to_param # this should set the new recent_group_id
#    get :index
#    
#    puts "index with :tab => #{groups(:one).name} called, @user.recent_group_id: #{@user.recent_group_id}"
#    
#    assert_no_tag(:tag => 'li', :content => "#{@current_tab}", :attributes => {:class => 'active_tab'})
#  end

  test 'search.present, tab.present, tab == all, recent_group_id.present' do
    @user = users(:one)
    sign_in @user
    puts "TEST: recent_group_id before: #{@user.recent_group_id}".red
    get :index, :tab => 'all', :search => 'uno'
    
    # assert that the all tab is active
    assert_tag(:tag => 'li', :content => 'all', :attributes => {:class => 'active_tab'})
    assert_tag(:tag => 'a', :content => 'uno')
    @user.update_recent_group_id("") # cheating
    puts "TEST: recent_group_id after: #{@user.recent_group_id}".red
    assert(@user.recent_group_id == nil)
    sign_out @user
  end
  
  test 'search.present, tab.present, tab == all, recent_group_id.nil' do
    @user = users(:two) # no recent_group_id assigned
    sign_in @user
    puts "TEST: recent_group_id before: #{@user.recent_group_id}".red
    get :index, :tab => 'all', :search => 'uno'
    
    # assert that the all tab is active
    assert_tag(:tag => 'li', :content => 'all', :attributes => {:class => 'active_tab'})
    assert_tag(:tag => 'a', :content => 'uno')
    puts "TEST: recent_group_id after: #{@user.recent_group_id}".red
    assert(@user.recent_group_id == nil)
    sign_out @user
  end

end

















