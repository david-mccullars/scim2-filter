module ParserSupport

  def self.included(base)
    base.class_eval do
      let(:handler) { Scim2::Filter::BaseHandler.new }
      let(:parser) { Scim2::Filter::Parser.new(handler) }

      subject do |example|
        parser.parse(example.description)
      end
    end
  end

  RSpec.configure do |config|
    config.include self, type: :parser
  end

  RSpec::Matchers.define :parse_into do |expected|
    match do |actual|
      actual == expected
    end
  end

end
