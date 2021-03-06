module Anise

  # The AnnotationStore tracks annotations on a per-class bases.
  #
  class AnnotationStore

    # Setup new Annotations instance.
    #
    # @param space [Class,Module]
    #   Class or Module to have annotations.
    #
    def initialize(space)
      @space = space
      @table = Hash.new { |h,k| h[k]={} }
    end

    # Ancestors of spaceal class/module.
    def ancestors
      @space.ancestors
    end

    # Annotations local to spaceal class/module.
    def local
      @table
    end

    # Access to local table.
    def [](ref, ns=:ann)
      @table[ns][ref]
    end

    # Lookup an annotation. Unlike `self[ref]`
    # this provides a complete annotation _heritage_,
    # pulling annotations of the same reference name
    # from ancestor classes and modules.
    #
    # Unlike the other annotation methods, this method takes
    # the `ref` argument before the `ns` argument. This is
    # it allow `ns` to default to the common annotator `ann`.
    #
    # @param ref [Object] Annotation reference key.
    #
    # @param ns [Symbol] Annotation namespace.
    #
    def lookup(ref=nil, ns=:ann)
      return @table if ref.nil?

      ref, ns = ref.to_sym, (ns || :ann).to_sym

      ann = {}
      ancestors.reverse_each do |anc|
        next unless anc.is_a?(Annotations)
        if h = anc.annotations.local[ns][ref]
          ann.merge!(h)
        end
      end
      return ann
    end

    # Set or read annotations.
    #
    # IMPORTANT! Do not use this for in-place modifications.
    # Use #annotate! instead.
    # 
    # @pararm ns [Symbol] Annotation namespace.
    #
    # @param ref [Object] Annotation reference key.
    #
    # @since 0.7.0
    def annotate(ns, ref, keys_or_class, keys=nil)
      if Class === keys_or_class
        keys ||= {}
        keys[:class] = keys_or_class
      else
        keys = keys_or_class
      end

      if Hash === keys
        update(ns, ref, keys)
      else
        key = keys.to_sym
        lookup(ref, ns)[key]
      end
    end

    # To change an annotation's value in place for a given class or module
    # it first must be duplicated, otherwise the change may effect annotations
    # in the class or module's ancestors.
    #
    # @pararm ns [Symbol] Annotation namespace.
    #
    # @param ref [Object] Annotation reference key.
    #
    # @since 0.7.0
    def annotate!(ns, ref, keys_or_class, keys=nil)
      if Class === keys_or_class
        keys ||= {}
        keys[:class] = keys_or_class
      else
        keys = keys_or_class
      end

      if Hash === keys
        update(ns, ref, keys)
      else
        key = keys.to_sym
        @table[ns][ref] ||= {}
        begin
          @table[ns][ref][key] = lookup(ref, ns)[key].dup
        rescue TypeError
          @table[ns][ref][key] = lookup(ref, ns)[key]
        end
      end
    end

    # Update annotations for a given namespace and reference.
    def update(ns, ref, hash)
      ref  = ref.to_sym

      @table[ns][ref] ||= {}

      hash.each do |k,v|
        @table[ns][ref][k.to_sym] = v
      end

      # callback
      @space.annotation_added(ref, ns) #if method_defined?(:annotation_added)
    end

  end

end
