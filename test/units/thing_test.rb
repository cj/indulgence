require_relative '../test_helper'
require 'user'
require 'thing'

class ThingTest < Test::Unit::TestCase
  
  def setup
    @god = Role.create(:name => 'god')
    @demigod = Role.create(:name => 'demigod')
    @owner = User.create(:name => 'Mary')
    @thing = Thing.create(:name => 'Stuff', :owner_id => @owner.id)
  end

  
  def test_user
    assert_equal(@owner, @thing.owner)
    assert_equal([@thing], @owner.things) 
  end
  
  def test_indulge
    make_second_thing
    assert_equal(true, @thing.indulge?(@owner, :read))
    assert_equal(false, @thing.indulge?(@owner, :delete))
    assert_equal(false, @other_thing.indulge?(@owner, :delete))
  end
  
  def test_indulge_by_god
    make_second_thing
    @owner.update_attribute(:role_id, @god.id)
    assert_equal(true, @thing.indulge?(@owner, :read))
    assert_equal(true, @thing.indulge?(@owner, :delete))
    assert_equal(true, @other_thing.indulge?(@owner, :delete))    
  end
  
  def test_indulge_by_demigod
    make_second_thing
    @owner.update_attribute(:role_id, @demigod.id)
    assert_equal(true, @thing.indulge?(@owner, :read))
    assert_equal(true, @thing.indulge?(@owner, :delete)) 
    assert_equal(false, @other_thing.indulge?(@owner, :delete))
  end
  
  def test_indulge_other_thing
    other_thing = OtherThing.create(:name => 'Other Stuff', :owner_id => @owner.id)
    assert_equal(true, other_thing.indulge?(@owner, :read))
    assert_equal(false, other_thing.indulge?(@owner, :delete))
  end
  
  def test_indulgence
    make_second_thing
    @owner.update_attribute(:role_id, @demigod.id)
    assert_equal(Thing.order('id'), Thing.indulgence(@owner, :read).order('id'))
    assert_equal(Thing.order('id'), Thing.indulgence(@user, :read).order('id'))
    assert_equal([@thing], Thing.indulgence(@owner, :delete))
    assert_raise ActiveRecord::RecordNotFound do
      Thing.indulgence(@user, :delete)
    end
  end
  
  def test_find
    make_second_thing
    @owner.update_attribute(:role_id, @demigod.id)
    assert_equal(@thing, Thing.indulgence(@owner, :delete).find(@thing.id))
    assert_raise ActiveRecord::RecordNotFound do
      assert_equal(@thing, Thing.indulgence(@user, :delete).find(@thing.id))
    end
  end
  
  def test_truth_method
    make_second_thing
    assert_equal(true, @thing.permit?(@owner, :read))
    assert_equal(false, @thing.permit?(@owner, :delete))
    assert_equal(false, @other_thing.permit?(@owner, :delete))
  end
  
  def test_where_method
    make_second_thing
    @owner.update_attribute(:role_id, @demigod.id)
    assert_equal(Thing.order('id'), Thing.permitted(@owner, :read).order('id'))
    assert_equal(Thing.order('id'), Thing.permitted(@user, :read).order('id'))
    assert_equal([@thing], Thing.permitted(@owner, :delete))
    assert_raise ActiveRecord::RecordNotFound do
      Thing.permitted(@user, :delete)
    end
  end
  
  def make_second_thing
    @user = User.create(:name => 'Clive')
    @other_thing = Thing.create(:name => 'Debris', :owner_id => @user.id)
  end
  
  def teardown
    Role.delete_all
    User.delete_all
    Thing.delete_all
  end
  
end