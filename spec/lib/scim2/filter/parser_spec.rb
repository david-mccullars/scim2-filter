require 'spec_helper'

describe Scim2::Filter::Parser, type: :parser do
  specify 'foo eq 99' do
    expect(subject).to parse_into(
      eq: {
        path:   [:foo],
        schema: nil,
        value:  99,
      },
    )
  end

  specify 'userName eq "bjensen"' do
    expect(subject).to parse_into(
      eq: {
        path:   [:userName],
        schema: nil,
        value:  'bjensen',
      },
    )
  end

  specify 'name.familyName co "O\'Malley"' do
    expect(subject).to parse_into(
      co: {
        path:   %i[name familyName],
        schema: nil,
        value:  "O'Malley",
      },
    )
  end

  specify 'userName sw "J"' do
    expect(subject).to parse_into(
      sw: {
        path:   [:userName],
        schema: nil,
        value:  'J',
      },
    )
  end

  specify 'urn:ietf:params:scim:schemas:core:2.0:User:userName sw "J"' do
    expect(subject).to parse_into(
      sw: {
        path:   [:userName],
        schema: 'urn:ietf:params:scim:schemas:core:2.0:User',
        value:  'J',
      },
    )
  end

  specify 'title pr' do
    expect(subject).to parse_into(
      pr: {
        path:   [:title],
        schema: nil,
        value:  nil,
      },
    )
  end

  specify 'meta.lastModified gt "2011-05-13T04:42:34Z"' do
    expect(subject).to parse_into(
      gt: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'meta.lastModified ge "2011-05-13T04:42:34Z"' do
    expect(subject).to parse_into(
      ge: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'meta.lastModified lt "2011-05-13T04:42:34Z"' do
    expect(subject).to parse_into(
      lt: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'meta.lastModified le "2011-05-13T04:42:34Z"' do
    expect(subject).to parse_into(
      le: {
        path:   %i[meta lastModified],
        schema: nil,
        value:  '2011-05-13T04:42:34Z',
      },
    )
  end

  specify 'title pr and userType eq "Employee"' do
    expect(subject).to parse_into(
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
    expect(subject).to parse_into(
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
    expect(subject).to parse_into(
      eq: {
        path:   [:schemas],
        schema: nil,
        value:  'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
      },
    )
  end

  specify 'userType eq "Employee" and (emails co "example.com" or emails.value co "example.org")' do
    expect(subject).to parse_into(
      and: [
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
        {
          group: {
            or: [
              {
                co: {
                  path:   [:emails],
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

  specify 'userType ne "Employee" and not (emails co "example.com" or emails.value co "example.org")' do
    expect(subject).to parse_into(
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
                  path:   [:emails],
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
    expect(subject).to parse_into(
      and: [
        {
          eq: {
            path:   [:userType],
            schema: nil,
            value:  'Employee',
          },
        },
        {
          group: {
            eq: {
              path:   %i[emails type],
              schema: nil,
              value:  'work',
            },
          },
        },
      ],
    )
  end

  specify 'userType eq "Employee" and emails[type eq "work" and value co "@example.com"]' do
    expect(subject).to parse_into(
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
          sub:    {
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
    expect(subject).to parse_into(
      or: [
        {
          path:   [:emails],
          schema: nil,
          sub:    {
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
          sub:    {
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
    expect(subject).to parse_into(
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
