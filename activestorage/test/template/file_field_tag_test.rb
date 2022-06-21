# frozen_string_literal: true

require "test_helper"
require "database/setup"
class ActiveStorage::FileFieldTagTest < ActionView::TestCase
  tests ActionView::Helpers::FormTagHelper

  test "file_field_tag has access to rails_direct_uploads_signed_validation_id" do
    expected = "<input data-direct-upload-url='http://test.host/rails/active_storage/direct_uploads' type='file' name='avatar' id='avatar' />"
    assert_dom_equal expected, file_field_tag("avatar", direct_upload: true)

    expected = "<input data-direct-upload-url='http://test.host/rails/active_storage/direct_uploads' data-direct-upload-signed-validation-id='#{User.new.avatar.to_signed_validation_id}' type='file' name='avatar' id='avatar' />"
    assert_dom_equal expected, file_field_tag("avatar", direct_upload: true, data: { direct_upload_signed_validation_id: User.new.avatar.to_signed_validation_id })
  end

  test "file_field has access to rails_direct_uploads_signed_validation_id" do
    expected = "<input data-direct-upload-url='http://test.host/rails/active_storage/direct_uploads' type='file' name='user[avatar]' id='user_avatar' />"
    assert_dom_equal expected, file_field("user", "avatar", direct_upload: true)

    expected = "<input data-direct-upload-url='http://test.host/rails/active_storage/direct_uploads' data-direct-upload-signed-validation-id='#{User.new.avatar.to_signed_validation_id}' type='file' name='user[avatar]' id='user_avatar' />"
    assert_dom_equal expected, file_field("user", "avatar", direct_upload: true, data: { direct_upload_signed_validation_id: User.new.avatar.to_signed_validation_id })
  end

  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    resources :users
  end
  include Routes.url_helpers

  def form_for(*)
    @output_buffer = super
  end

  test "form builder includes direct upload attributes" do
    @user = User.create!(name: "DHH")

    form_for(@user) do |f|
      concat f.file_field(:avatar, direct_upload: true)
    end

    expected = %Q(<input data-direct-upload-url="http://test.host/rails/active_storage/direct_uploads" data-direct-upload-signed-validation-id="#{@user.avatar.to_signed_validation_id}" type="file" name="user[avatar]" id="user_avatar" />)

    assert_includes output_buffer, expected
  end
end
