class TransactionalTestCase < Test::Unit::TestCase

  def run(result, &block)
    # Handle the default "you have no tests" test if it turns up
    return if @method_name.to_s == "default_test"
    ActiveRecord::Base.transaction do
      load_fixtures
      result = super(result, &block)
      raise ActiveRecord::Rollback
    end
    result
  end

  protected

  def load_fixtures
    fixtures = YAML.load_file(
      File.join(File.dirname(__FILE__), '..', 'fixtures', 'dc.yml')
    )
    fields_per_publication = 20
    disable_logging do
      count = 0
      publication = nil
      fixtures.keys.sort.each do |key|
        publication ||= DCPublication.create(name: "Pub ##{DCPublication.count + 1}", available_from: DateTime.current)
        DCField.create(fixtures[key].merge(dc_publication_id: publication.id))
        count += 1
        if count == fields_per_publication
          count = 0
          publication = nil
        end
      end
    end
  end

  def disable_logging
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    yield
    ActiveRecord::Base.logger = logger
  end

end