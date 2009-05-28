= Creating and Reading Annotations

Load the primary annotations library.

  require 'anise/annotation'

Given a example class X we can apply annotations to it using the #ann method. 

  class X
    include Anise::Annotation
    ann :x1, :a=>1
    ann :x1, :b=>2
  end

We can then use #ann to lookup the set annotations.

  X.ann(:x1,:a).should == 1

The #ann method is a public interface, so we can define annotation externally as well.

   X.ann :x1, :a => 2
   X.ann(:x1, :a).should == 2

QED.

