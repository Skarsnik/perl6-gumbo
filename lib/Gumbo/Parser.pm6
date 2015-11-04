use XML;
use HTML::Parser;

use NativeCall;
use Gumbo::Binding;

unit class Gumbo::Parser does HTML::Parser;

has Duration $.c_parse_duration;
has Duration $.xml_creation_duration;

method parse (Str $html, *%filters) returns XML::Document {
    #gumbo-type-size();
    #explicitly-manage($html);
    my $t = now;
    
    if (%filters.elems > 0) {
      die "Gumbo, parse_html : No TAG specified in the filter" unless %filters<TAG>.defined;
      die "Gumbo, parse_html : Filters only allow 3 elements, did you try to filter on more than one attribute?" if %filters.elems > 3;
    }
    
    my gumbo_output_t $gumbo_output = gumbo_parse($html);
    $!c_parse_duration = now - $t;
    $t = now;
    my gumbo_output_s $go = nativecast(gumbo_output_s, $gumbo_output);
    my gumbo_node_s $groot = nativecast(gumbo_node_s, $go.root);
    my gumbo_node_s $gdoc = nativecast(gumbo_node_s, $go.document);
    if ($groot.type eq GUMBO_NODE_ELEMENT.value) {
      my $htmlroot = build-element($groot.v.element);
      my $tab_child = nativecast(CArray[gumbo_node_t], $groot.v.element.children.data);
      loop (my $i = 0; $i < $groot.v.element.children.length; $i++) {
	build-tree(nativecast(gumbo_node_s, $tab_child[$i]), $htmlroot) if %filters.elems eq 0;
	if %filters.elems > 0 {
	  my $ret = build-tree2(nativecast(gumbo_node_s, $tab_child[$i]), $htmlroot, %filters);
	  last unless $ret;
	}
      }
      $!xmldoc = XML::Document.new: root => $htmlroot;
    }
    if ($gdoc.type eq GUMBO_NODE_DOCUMENT.value) {
      my gumbo_document_s $cgdoc = $gdoc.v.document;
      my $tab_child = nativecast(CArray[gumbo_node_t], $cgdoc.children.data);
      loop (my $i = 0; $i < $cgdoc.children.length; $i++) {
	my $node = nativecast(gumbo_node_s, $tab_child[$i]);
	if ($node.type eq GUMBO_NODE_COMMENT.value)
	{
	  #No idea what to do, it probably catch comments outside the html tag
	}
      }
    }
    $!xml_creation_duration = now - $t;
    return $!xmldoc;
  }

  sub	build-tree(gumbo_node_s $node, XML::Element $parent is rw) {
    given $node.type {
      when GUMBO_NODE_ELEMENT.value {
        my $xml = build-element($node.v.element);
        $parent.append($xml);
        my $tab_child = nativecast(CArray[gumbo_node_t], $node.v.element.children.data);
	loop (my $i = 0; $i < $node.v.element.children.length; $i++) {
	  build-tree(nativecast(gumbo_node_s, $tab_child[$i]), $xml);
	}
      }
      when GUMBO_NODE_TEXT.value | GUMBO_NODE_WHITESPACE.value {
        my $xml = XML::Text.new(text => $node.v.text.text);
        $parent.append($xml);
      }
      when GUMBO_NODE_COMMENT.value {
        my $xml = XML::Comment.new: data => $node.v.text.text;
        $parent.append($xml);
      }
      when GUMBO_NODE_CDATA.value {
        my $xml = XML::CData.new: data => $node.v.text.text;
        $parent.append($xml);
      }
    }
  }
  # Only filter some elements
  sub	build-tree2(gumbo_node_s $node, XML::Element $parent is rw, %filters) returns Bool {
    my $in_filter = False;
    given $node.type {
      when GUMBO_NODE_ELEMENT.value {
        my $xml;
        if (%filters<TAG> eq gumbo_normalized_tagname($node.v.element.tag)) {
          my $elem := $node.v.element;
	  if ($elem.attributes.defined && (%filters.elems > 1 && !%filters<SINGLE>.defined || %filters.elems > 2 && %filters<SINGLE>.defined)) {
	    my $tab_attr = nativecast(CArray[gumbo_attribute_t], $elem.attributes.data);
	    loop (my $i = 0; $i < $elem.attributes.length; $i++) {
	      my $cattr = nativecast(gumbo_attribute_s, $tab_attr[$i]);
	      {$in_filter = True; last } if (%filters{$cattr.name}.defined && %filters{$cattr.name} eq $cattr.value);
	    }
	  }
	  #No filtering on attributes
	  if ((%filters.elems eq 1 && !%filters<SINGLE>.defined || 
	       %filters.elems eq 2 && %filters<SINGLE>.defined)) {
	    $in_filter = True;
	  }
	  if ($in_filter) {
	    $xml = build-element($node.v.element);
	    $parent.append($xml);
	  }
	}
        my $tab_child = nativecast(CArray[gumbo_node_t], $node.v.element.children.data);
	loop (my $i = 0; $i < $node.v.element.children.length; $i++) {
	  my $ret = True;
	  build-tree(nativecast(gumbo_node_s, $tab_child[$i]), $xml) if $in_filter;
	  $ret = build-tree2(nativecast(gumbo_node_s, $tab_child[$i]), $parent, %filters) if !$in_filter;
	  return False unless $ret;
	}
	return False if $in_filter && %filters<SINGLE>.defined;
      }
     }
     return True;
  }
  
  sub build-element(gumbo_element_s $elem) {
    my $xml = XML::Element.new;
    $xml.name = gumbo_normalized_tagname($elem.tag);
    return $xml unless $elem.attributes.defined;
    my $tab_attr = nativecast(CArray[gumbo_attribute_t], $elem.attributes.data);
    loop (my $i = 0; $i < $elem.attributes.length; $i++) {
      my $cattr = nativecast(gumbo_attribute_s, $tab_attr[$i]);
      $xml.attribs{$cattr.name} = $cattr.value;
    }
    return $xml;
  }