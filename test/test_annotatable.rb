require 'anise/annotatable'

class Test_Annotatable < Test::Unit::TestCase

  class X
    include Anise::Annotatable

    annotation :req

    req 'r'

    def a ; "a"; end

    req 's'

    attr :b
  end

  def test_annotated
    assert_equal( {:req=>['r']}, X.ann(:a) )
  end

  def test_annotated
    assert_equal( {:req=>['s']}, X.ann(:b) )
  end

end

