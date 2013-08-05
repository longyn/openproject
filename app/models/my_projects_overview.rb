#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 Finn GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See LICENSE for more details.
#++

class MyProjectsOverview < ActiveRecord::Base
  unloadable

  after_initialize :initialize_default_values

  DEFAULTS = {
    "left" => ["projectdescription", "projectdetails", "issuetracking"],
    "right" => ["members", "news"],
    "top" => [],
    "hidden" => [] }

  def initialize_default_values()
    # attributes() creates a copy every time it is called, so better not use it in a loop
    # (this is also why we send the default-values instead of just setting it on attributes)
    attr = attributes()

    DEFAULTS.each_key do |attribute_name|
      self.send("#{attribute_name}=",DEFAULTS[attribute_name])  if attr[attribute_name].nil?
    end
  end

  serialize :top
  serialize :left
  serialize :right
  serialize :hidden
  belongs_to :project

  validate :fields_are_arrays

  acts_as_attachable :delete_permission => :edit_project, :view_permission => :view_project

  def fields_are_arrays
    Array === top && Array === left && Array === right && Array === hidden
  end

  def save_custom_element(name, title, new_content)
    el = custom_elements.detect {|x| x.first == name}
    return unless el
    el[1] = title
    el[2] = new_content
    save
  end

  def new_custom_element
    idx = custom_elements.any? ? custom_elements.sort.last.first.next : "a"
    [idx, l(:label_custom_element), "h3. #{l(:info_custom_text)}"]
  end

  def elements
    top + left + right + hidden
  end

  def custom_elements
    elements.select {|x| x.respond_to? :to_ary }
  end

  def attachments_visible?(user)
    true
  end
end
