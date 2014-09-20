module Tfidf
  def tf(freq, word_count)
    freq.to_f / word_count.to_f
  end

  def idf(document_count, freq_document)
    log(document_count.to_f / freq_document.to_f)
  end

  def tfidf(freq_w, w_count, d_count, freq_d)
    tf(freq_w, w_count) * idf(d_count, freq_d)
  end
end
