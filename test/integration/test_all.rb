require 'anise'

# The intent of this testcase is test the variant annotaiton modules
# in conjunction, to make sure they can all be used together without
# conflict.
#
# All good intentions aside these cases need HELP, as they are really other
# cases just thrown together and not really thought out as such. Still,
# something is better than nothing.

Test.case "Integration" do

  context "using an annotation for attribute validation" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      attr :a

      annotator :ann
      ann :@a, :valid => lambda{ |x| x.is_a?(Integer) }
      ann :a, :class => Integer

      def initialize(a)
        @a = a
      end

      def validate
        instance_variables.each do |iv|
          if validator = self.class.ann(iv)[:valid]
            value = instance_variable_get(iv)
            unless validator.call(value)
              raise "Invalid value #{value} for #{iv}"
            end
          end
        end
      end
    end

    test "class" do
      cX.ann(:a, :class) == Integer
    end

    test "validate" do
      x = cX.new(1)
      x.validate
    end

  end

  context "2" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      def x1 ; end

      annotator :ann
      ann :x1, :a=>1
      ann :x1, :b=>2
    end

    test "01" do
      cX.ann(:x1,:a) == cX.ann(:x1,:a)
    end

    test "02" do
      cX.ann(:x1,:a).object_id == cX.ann(:x1,:a).object_id
    end

    test "03" do
      cX.ann :x1, :a => 2
      cX.ann(:x1,:a) == 2
    end

  end

  context "3" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      def x1 ; end

      annotator :ann
      ann :x1, :a=>1
      ann :x1, :b=>2
    end

    cY = Class.new(cX)

    test "01" do
      cY.ann(:x1,:a) == cY.ann(:x1,:a)
    end

    test "02" do
      cY.ann(:x1,:a).object_id == cY.ann(:x1,:a).object_id
    end

    test "03" do
      cY.ann(:x1,:a) == 1
    end

    test "04" do
      cY.ann(:x1,:b) == 2
    end

    test "05" do
      cY.ann :x1,:a => 2
      cY.ann(:x1,:a) == 2 &&
      cY.ann(:x1,:b) == 2
    end

  end

  context "4" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      annotator :ann
      ann :foo, Integer
    end

    cY = Class.new(cX) do
      ann :foo, String
    end

    test "01" do
      cX.ann(:foo, :class) == Integer
    end

    test "02" do
      cY.ann(:foo, :class) == String
    end

  end

  context "5" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      annotator :ann
      ann :foo, :doc => "hello"
      ann :foo, :bar => []
    end

    cY = Class.new(cX) do
      ann :foo, :class => String, :doc => "bye"
    end

    test "01" do
      cX.ann(:foo,:doc) == "hello"
    end

    test "02" do
      cX.ann(:foo) == {:doc=>"hello", :bar=>[]} 
    end

    test "03" do
      cX.ann(:foo,:bar) << "1"
      cX.ann(:foo,:bar) == ["1"]
    end

    test "04" do
      cY.ann(:foo,:doc) == "bye"
    end

    test "05" do
      #cY.ann(:foo,:bar) == nil
      cY.ann(:foo,:bar) == ["1"]
    end

    test "06" do
      cY.ann(:foo, :doc => "cap")
      cY.ann(:foo, :doc) == "cap"
    end

    test "07" do
      cY.ann!(:foo,:bar) << "2"
      cY.ann(:foo,:bar) == ["1", "2"] &&
      cX.ann(:foo,:bar) == ["1"]
    end

  end

  context "6" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      method_annotator :req

      req 'r'
      def a ; "a"; end

      req 's', 't'
      attr :b
    end

    test "annotated" do
      cX.ann(:a) == {:req=>'r'}
    end

    test "annotated" do
      cX.ann(:b) == {:req=>['s','t']}
    end

  end

  context "attribute" do

    cX = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      attr :q
      attr :a, :x => 1
    end

    test "a" do
      cX.ann(:a) == {:x=>1}
    end

  end

  context "attribute using attr" do

    cA = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      attr :x, :cast=>"to_s"
    end

    test "cast" do
      cA.ann(:x,:cast) == "to_s"
    end

  end

  context "attribute using attr_accessor" do

    cA = Class.new do
      include Anise::Annotation
      include Anise::Method
      include Anise::Attribute

      attr_accessor :x, :cast=>"to_s"
    end

    test "instance_attributes" do
      iv = cA.instance_attributes - [:taguri]
      iv == [:x]
    end

  end

end
