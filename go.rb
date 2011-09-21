require 'java'
require 'lib/lucene-core-3.1.0.jar'

module Lucene
  module Store
    include_package 'org.apache.lucene.store'
  end
  module Index
    include_package 'org.apache.lucene.index'
  end
  module Doc
    include_package 'org.apache.lucene.document'
  end
  module Search
    include_package 'org.apache.lucene.search'
  end

  module TokenAttributes
    include_package 'org.apache.lucene.analysis.tokenattributes'
  end

  StandardTokenizer = org.apache.lucene.analysis.standard.StandardTokenizer
  Version = org.apache.lucene.util.Version
end

# Tokenization (This is hideous, it's lucene's fault)
puts 'Tokens'
t = Lucene::StandardTokenizer.new(Lucene::Version::LUCENE_CURRENT, java.io.StringReader.new("I am 127.0.0.1"))
charTermAttribute = t.getAttribute Lucene::TokenAttributes::CharTermAttribute.java_class
while t.incrementToken
  puts charTermAttribute.to_s
end
puts

# Create an index and add some documents to the index
index = Lucene::Store::FSDirectory.open(java.io.File.new('test.index'))
analyzer = org.apache.lucene.analysis.standard.StandardAnalyzer.new(org.apache.lucene.util.Version::LUCENE_30)
writer = Lucene::Index::IndexWriter.new(index, analyzer, Lucene::Index::IndexWriter::MaxFieldLength::UNLIMITED)
doc = Lucene::Doc::Document.new
doc.add(Lucene::Doc::Field.new("id", "1", Lucene::Doc::Field::Store::YES, Lucene::Doc::Field::Index::NOT_ANALYZED))
doc.add(Lucene::Doc::Field.new("title", "some document", Lucene::Doc::Field::Store::YES, Lucene::Doc::Field::Index::ANALYZED))
doc.add(Lucene::Doc::Field.new("body", "this is longer text that has some content that we want to save", Lucene::Doc::Field::Store::YES, Lucene::Doc::Field::Index::ANALYZED))
writer.add_document(doc)
doc = Lucene::Doc::Document.new
doc.add(Lucene::Doc::Field.new("id", "2", Lucene::Doc::Field::Store::YES, Lucene::Doc::Field::Index::NOT_ANALYZED))
doc.add(Lucene::Doc::Field.new("title", "some other document", Lucene::Doc::Field::Store::YES, Lucene::Doc::Field::Index::ANALYZED))
doc.add(Lucene::Doc::Field.new("body", "that has some more content which is longer than the title for which this blah blah", Lucene::Doc::Field::Store::YES, Lucene::Doc::Field::Index::ANALYZED))
writer.add_document(doc)
writer.close

# searching the index
puts 'searching'
searcher = Lucene::Search::IndexSearcher.new(Lucene::Store::FSDirectory.open(java.io.File.new('test.index')));
t = Lucene::Index::Term.new("title", "some");
query = Lucene::Search::TermQuery.new(t);
docs = searcher.search(query, 10);
docs.totalHits.times do |i|
  puts searcher.doc(docs.scoreDocs[i].doc).get("title")
end
puts

# get the term frequencies of a term
reader = Java::OrgApacheLuceneIndex::IndexReader.open(index)
t = org.apache.lucene.index.Term.new("title", "some")
freqs = reader.term_docs(t)
term_count = 0
while(freqs.next)
  term_count = term_count + freqs.freq
end
puts "Term Count for 'some': " + term_count.to_s
puts



