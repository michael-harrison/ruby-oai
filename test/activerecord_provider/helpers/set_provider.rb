# Extend ActiveRecordModel to support sets
class SetModel < OAI::Provider::ActiveRecordWrapper

  # Return all available sets
  def sets
    DCSet.scoped
  end

end

class SetModelCached < OAI::Provider::ActiveRecordCachingWrapper

  # Return all available sets
  def sets
    DCSet.scoped
  end

end

class ARSetProvider < OAI::Provider::Base
  repository_name 'ActiveRecord Set Based Provider'
  repository_url 'http://localhost'
  record_prefix = 'oai:test'
  source_model SetModel.new(DCField, :timestamp_field => 'date')
end

class ARExclusiveSetProvider < OAI::Provider::Base
  repository_name 'ActiveRecord Set Based Provider'
  repository_url 'http://localhost'
  record_prefix = 'oai:test'
  source_model OAI::Provider::ActiveRecordWrapper.new(
    ExclusiveSetDCField, :timestamp_field => 'date')
end

class CachingSetResumptionProvider < OAI::Provider::Base
  repository_name 'ActiveRecord Caching Resumption Provider'
  repository_url 'http://localhost'
  record_prefix 'oai:test'
  source_model SetModelCached.new(DCField, :limit => 25)
end


