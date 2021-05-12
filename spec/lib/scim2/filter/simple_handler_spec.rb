require 'spec_helper'

describe Scim2::Filter::SimpleHandler do
  let(:handler) { Scim2::Filter::SimpleHandler.new }
  let(:parser) { Scim2::Filter::Parser.new(handler) }

  let(:parsed_result) do |example|
    parser.parse(example.description)
  end

  specify 'foo eq 99' do
    expect(parsed_result).to eq(
      eq: {
        path:   [:foo],
        schema: nil,
        value:  99,
      },
    )
  end

  specify 'userName eq "bjensen"' do
    expect(parsed_result).to eq(
      eq: {
        path:   [:userName],
        schema: nil,
        value:  'bjensen',
      },
    )
  end

  specify 'name.familyName co "O\'Malley"' do
    expect(parsed_result).to eq(
      co: {
        path:   %i[name familyName],
        schema: nil,
        value:  "O'Malley",
      },
    )
  end

  specify 'userName sw "J"' do
    expect(parsed_result).to eq(
      sw: {
        path:   [:userName],
        schema: nil,
        value:  'J',
      },
    )
  end

  specify 'urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"' do
    expect(parsed_result).to eq(
      sw: {
        path:   [:userName],
        schema: 'urn:ietf:params:scim:schemas:core:2.0:User',
        value:  'J',
      },
    )
  end

  specify 'title pr' do
    expect(parsed_result).to eq(
      pr: {
        path:   [:title],
        schema: nil,
        value:  nil,
      },
    )
  end

  specify 'meta.lastModified gt "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to eq(
      gt: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'meta.lastModified ge "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to eq(
      ge: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'meta.lastModified lt "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to eq(
      lt: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'meta.lastModified le "2011-05-13T04:42:34Z"' do
    expect(parsed_result).to eq(
      le: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'title pr and userType eq "Employee"' do
    expect(parsed_result).to eq(
      and: [
        {
          pr: {
            path:   [:title],
            schema: nil,
            value:  nil,
          },
        },
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
      ],
    )
  end

  specify 'title pr or userType eq "Intern"' do
    expect(parsed_result).to eq(
      or: [
        {
          pr: {
            path:   [:title],
            schema: nil,
            value:  nil,
          },
        },
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Intern',
          },
        },
      ],
    )
  end

  specify 'schemas eq "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"' do
    expect(parsed_result).to eq(
      eq: {
        path:   [:schemas],
        schema: nil,
        value:  'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
      },
    )
  end

  specify 'userType eq "Employee" and (emails.value co "example.com" or emails.value co "example.org")' do
    expect(parsed_result).to eq(
      and: [
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
        {
          or: [
            {
              co: {
                path:   %i[emails value],
                schema: nil,
                value:  'example.com',
              },
            },
            {
              co: {
                path:   %i[emails value],
                schema: nil,
                value:  'example.org',
              },
            },
          ],
        },
      ],
    )
  end

  specify 'userType ne "Employee" and not (emails.value co "example.com" or emails.value co "example.org")' do
    expect(parsed_result).to eq(
      and: [
        {
          ne: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
        {
          not: {
            or: [
              {
                co: {
                  path:   %i[emails value],
                  schema: nil,
                  value:  'example.com',
                },
              },
              {
                co: {
                  path:   %i[emails value],
                  schema: nil,
                  value:  'example.org',
                },
              },
            ],
          },
        },
      ],
    )
  end

  specify 'userType eq "Employee" and (emails.type eq "work")' do
    expect(parsed_result).to eq(
      and: [
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
        {
          eq: {
            path:   %i[emails type],
            schema: nil,
            value:  'work',
          },
        },
      ],
    )
  end

  specify 'userType eq "Employee" and emails[type eq "work" and value co "@example.com"]' do
    expect(parsed_result).to eq(
      and: [
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
        {
          path:   [:emails],
          schema: nil,
          nested: {
            and: [
              {
                eq: {
                  path:   [:type],
                  schema: nil,
                  value:  'work',
                },
              },
              {
                co: {
                  path:   [:value],
                  schema: nil,
                  value:  '@example.com',
                },
              },
            ],
          },
        },
      ],
    )
  end

  specify 'emails[type eq "work" and value co "@example.com"] or ims[type eq "xmpp" and value co "@foo.com"]' do
    expect(parsed_result).to eq(
      or: [
        {
          path:   [:emails],
          schema: nil,
          nested: {
            and: [
              {
                eq: {
                  path:   [:type],
                  schema: nil,
                  value:  'work',
                },
              },
              {
                co: {
                  path:   [:value],
                  schema: nil,
                  value:  '@example.com',
                },
              },
            ],
          },
        },
        {
          path:   [:ims],
          schema: nil,
          nested: {
            and: [
              {
                eq: {
                  path:   [:type],
                  schema: nil,
                  value:  'xmpp',
                },
              },
              {
                co: {
                  path:   [:value],
                  schema: nil,
                  value:  '@foo.com',
                },
              },
            ],
          },
        },
      ],
    )
  end

  # Order of operations -- AND has higher priority than OR
  specify 'w pr and x pr or y pr and z pr' do
    expect(parsed_result).to eq(
      or: [
        {
          and: [
            {
              pr: {
                path:   [:w],
                schema: nil,
                value:  nil,
              },
            },
            {
              pr: {
                path:   [:x],
                schema: nil,
                value:  nil,
              },
            },
          ],
        },
        {
          and: [
            {
              pr: {
                path:   [:y],
                schema: nil,
                value:  nil,
              },
            },
            {
              pr: {
                path:   [:z],
                schema: nil,
                value:  nil,
              },
            },
          ],
        },
      ],
    )
  end
end
