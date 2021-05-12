require 'spec_helper'

describe Scim2::Filter::ArelHandler do
  before(:all) do
    require 'active_record'
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  end

  let(:table) { Arel::Table.new(:users) }
  let(:handler) { Scim2::Filter::ArelHandler.new(mapping) }
  let(:parser) { Scim2::Filter::Parser.new(handler) }
  let(:mapping) do
    {
      foo:      table[:foo],
      userType: table[:type],
      userName: table[:user_name],
      name:     {
        familyName: table[:family_name],
      },
      title:    table[:title3],
      meta:     {
        lastModified: table[:last_modified],
      },
      schemas:  table[:schemas],
      emails:   {
        value: table[:email],
        type:  table[:email_type],
      },
      type:     table[:ignored],
      value:    table[:ignored],
      w:        table[:w],
      x:        table[:x],
      y:        table[:y],
      z:        table[:z],
    }
  end

  let(:parsed_result) do |example|
    parser.parse(example.description)
  end

  specify 'foo eq 99' do
    expect(parsed_result).to produce_sql %(
      "users"."foo" = 99
    )
  end

  specify 'userName eq "bjensen"' do
    expect(parsed_result).to produce_sql %(
      "users"."user_name" = 'bjensen'
    )
  end

  specify 'name.familyName co "O\'Malley"' do
    expect(parsed_result).to produce_sql %(
      "users"."family_name" LIKE '%O''Malley%'
    )
  end

  specify 'userName sw "J"' do
    expect(parsed_result).to produce_sql %(
      "users"."user_name" LIKE 'J%'
    )
  end

  specify 'urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"' do
    expect(parsed_result).to produce_sql %(
      "users"."user_name" LIKE 'J%'
    )
  end

  specify 'title pr' do
    expect(parsed_result).to produce_sql %(
      "users"."title3" IS NOT NULL
    )
  end

  specify 'meta.lastModified gt "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to produce_sql %(
      "users"."last_modified" > '2011-05-13T04:42:34Z'
    )
  end

  specify 'meta.lastModified ge "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to produce_sql %(
      "users"."last_modified" >= '2011-05-13T04:42:34Z'
    )
  end

  specify 'meta.lastModified lt "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to produce_sql %(
      "users"."last_modified" < '2011-05-13T04:42:34Z'
    )
  end

  specify 'meta.lastModified le "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to produce_sql %(
      "users"."last_modified" <= '2011-05-13T04:42:34Z'
    )
  end

  specify 'title pr and userType eq "Employee"' do
    expect(parsed_result).to produce_sql %(
      "users"."title3" IS NOT NULL AND "users"."type" = 'Employee'
    )
  end

  specify 'title pr or userType eq "Intern"' do
    expect(parsed_result).to produce_sql %(
      ("users"."title3" IS NOT NULL OR "users"."type" = 'Intern')
    )
  end

  specify 'schemas eq "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"' do
    expect(parsed_result).to produce_sql %(
      "users"."schemas" = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'
    )
  end

  specify 'userType eq "Employee" and (emails.value co "example.com" or emails.value co "example.org")' do
    expect(parsed_result).to produce_sql %(
      "users"."type" = 'Employee' AND ("users"."email" LIKE '%example.com%' OR "users"."email" LIKE '%example.org%')
    )
  end

  specify 'userType ne "Employee" and not (emails.value co "example.com" or emails.value co "example.org")' do
    expect(parsed_result).to produce_sql %(
      "users"."type" != 'Employee' AND NOT (("users"."email" LIKE '%example.com%' OR "users"."email" LIKE '%example.org%'))
    )
  end

  specify 'userType eq "Employee" and (emails.type eq "work")' do
    expect(parsed_result).to produce_sql %(
      "users"."type" = 'Employee' AND "users"."email_type" = 'work'
    )
  end

  specify 'userType eq "Employee" and emails[type eq "work" and value co "@example.com"]' do
    expect { parsed_result }.to raise_error(/Nested attributes are not currently supported/i)
  end

  specify 'emails[type eq "work" and value co "@example.com"] or ims[type eq "xmpp" and value co "@foo.com"]' do
    expect { parsed_result }.to raise_error(/Nested attributes are not currently supported/i)
  end

  # Order of operations -- AND has higher priority than OR (also true in SQL)
  specify 'w pr and x pr or y pr and z pr' do
    expect(parsed_result).to produce_sql %(
      ("users"."w" IS NOT NULL AND "users"."x" IS NOT NULL OR "users"."y" IS NOT NULL AND "users"."z" IS NOT NULL)
    )
  end

  RSpec::Matchers.define :produce_sql do |expected|
    expected = expected.strip
    match do |actual|
      actual = actual.to_sql.strip
      actual == expected
    end
    failure_message do |actual|
      <<~MESSAGE
        expected #{actual.to_sql.strip}
             got #{expected}
      MESSAGE
    end
  end
end
