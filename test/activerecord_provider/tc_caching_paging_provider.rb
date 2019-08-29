require 'test_helper'

class CachingPagingProviderTest < TransactionalTestCase
  include REXML

  def test_full_harvest
    doc = Document.new(@provider.list_records(:metadata_prefix => 'oai_dc'))
    assert_not_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
    assert_equal 26, doc.elements["/OAI-PMH/ListRecords"].size
    token = doc.elements["/OAI-PMH/ListRecords/resumptionToken"].text
    doc = Document.new(@provider.list_records(:resumption_token => token))
    assert_not_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
    token = doc.elements["/OAI-PMH/ListRecords/resumptionToken"].text
    assert_equal 26, doc.elements["/OAI-PMH/ListRecords"].size
    doc = Document.new(@provider.list_records(:resumption_token => token))
    assert_not_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
    token = doc.elements["/OAI-PMH/ListRecords/resumptionToken"].text
    assert_equal 26, doc.elements["/OAI-PMH/ListRecords"].size
    doc = Document.new(@provider.list_records(:resumption_token => token))
    assert_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
    assert_equal 25, doc.elements["/OAI-PMH/ListRecords"].size
  end

  def test_from_and_until
    first_id = DCField.find(:first, :order => "dc_fields.id asc").id
    DCField.unscoped.update_all(['updated_at = ?', Time.parse("September 15 2005")],
                                "id <= #{first_id + 25}")
    DCField.unscoped.update_all(['updated_at = ?', Time.parse("November 1 2005")],
                                "id < #{first_id + 50} and id > #{first_id + 25}")

    # Should return 50 records broken into 2 groups of 25.
    doc = Document.new(
      @provider.list_records(
        :metadata_prefix => 'oai_dc',
        :from => Time.parse("September 1 2005"),
        :until => Time.parse("November 30 2005"))
    )
    assert_equal 26, doc.elements["/OAI-PMH/ListRecords"].size
    token = doc.elements["/OAI-PMH/ListRecords/resumptionToken"].text
    assert_not_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
    doc = Document.new(@provider.list_records(:resumption_token => token))
    assert_equal 25, doc.elements["/OAI-PMH/ListRecords"].size
    assert_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
  end

  def test_default_scope_support
    total_field_count = DCField.unscoped.count
    first_id = DCField.find(:first, :order => "dc_fields.id asc").id
    publication_next_month = DCPublication.create(name: 'Next Month', available_from: 1.month.since(Date.today))
    DCField.unscoped.update_all(['dc_publication_id = ?', publication_next_month.id], "id > #{first_id + 49}")

    # Should return 50 records broken into 2 groups of 25.
    doc = Document.new(
      @provider.list_records(
        metadata_prefix: 'oai_dc',
        from: Date.yesterday.to_time
      )
    )

    assert_equal 26, doc.elements["/OAI-PMH/ListRecords"].size # 25 records + 1 resumption token
    token = doc.elements["/OAI-PMH/ListRecords/resumptionToken"].text
    assert_not_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
    doc = Document.new(@provider.list_records(:resumption_token => token))
    assert_equal 25, doc.elements["/OAI-PMH/ListRecords"].size
    assert_nil doc.elements["/OAI-PMH/ListRecords/resumptionToken"]
  end

  def setup
    @provider = CachingResumptionProvider.new
  end

end
