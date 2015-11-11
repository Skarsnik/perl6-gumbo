
use NativeCall;

=begin pod

This module held the gumbo type and C function binded.
Look at the source code (it containt the original definition of the c struct)

=end pod

module Gumbo::Binding {
  class gumbo_node_t is repr('CPointer') is export {};
  class gumbo_output_t is repr('CPointer') is export {};
  class gumbo_attribute_t is repr('CPointer') is export {};
  

  enum gumbo_node_type is export (
     GUMBO_NODE_DOCUMENT => 0,
     GUMBO_NODE_ELEMENT => 1,
     GUMBO_NODE_TEXT => 2,
     GUMBO_NODE_CDATA => 3,
     GUMBO_NODE_COMMENT => 4,
     GUMBO_NODE_WHITESPACE => 5,
     GUMBO_NODE_TEMPLATE => 6
  );
  
#   typedef struct {
#    68   unsigned int line;
#    69   unsigned int column;
#    70   unsigned int offset;
#    71 } GumboSourcePosition;

  class gumbo_source_position is repr('CStruct') is export {
    has uint32	$.line;
    has uint32	$.column;
    has uint32	$.offset;
  }
#   typedef struct {
#    90   const char* data;
#    91 
#    93   size_t length;
#    94 } GumboStringPiece;
#   
  class gumbo_string_piece_s is repr('CStruct') is export {
    has Str		$.data;
    has uint32		$.length;
  }
  
  #    typedef struct {
#      void** data;
#    
#      unsigned int length;
#    
#      unsigned int capacity;
#    } GumboVector;
  
  class gumbo_vector_s is repr('CStruct') is export {
    has OpaquePointer $.data;
    has uint32        $.length;
    has uint32	      $.capacity; 
  }
  
    #typedef struct {
  #   GumboVector /* GumboNode* */ children;
  # 
  #   // True if there was an explicit doctype token as opposed to it being omitted.
#      bool has_doctype;
#    
#      // Fields from the doctype token, copied verbatim.
#      const char* name;
#      const char* public_identifier;
#      const char* system_identifier;
#    
#      GumboQuirksModeEnum doc_type_quirks_mode;
#    } GumboDocument;
#   
  class gumbo_document_s is repr('CStruct') is export {
     HAS gumbo_vector_s $.children;
     has int8		$.has_doctype;
     has Str		$.name;
     has Str		$.public_identifier;
     has Str		$.system_identifier;
     has int32		$.doc_type_quirks_mode;
  }

  
#   typedef struct {
#   231   GumboAttributeNamespaceEnum attr_namespace;
#   232 
#   237   const char* name;
#   238 
#   243   GumboStringPiece original_name;
#   244 
#   251   const char* value;
#   252 
#   261   GumboStringPiece original_value;
#   262 
#   264   GumboSourcePosition name_start;
#   265 
#   271   GumboSourcePosition name_end;
#   272 
#   274   GumboSourcePosition value_start;
#   275 
#   277   GumboSourcePosition value_end;
#   278 } GumboAttribute;
#   279 
#   
  class gumbo_attribute_s is repr('CStruct') is export {
    has	int32			$.attr_namespace;
    has Str			$.name;
    HAS gumbo_string_piece_s	$.original_name;
    has Str			$.value;
    HAS gumbo_string_piece_s	$.original_value;
    HAS gumbo_source_position	$.name_start;
    HAS gumbo_source_position	$.name_end;
    HAS gumbo_source_position	$.value_start;
    HAS gumbo_source_position	$.value_end;
  }

#   typedef struct {
#   453   const char* text;
#   454 
#   459   GumboStringPiece original_text;
#   460 
#   465   GumboSourcePosition start_pos;
#   466 } GumboText;

    class gumbo_text_s is repr('CStruct') is export {
      has Str			$.text;
      HAS gumbo_string_piece_s	$.original_text;
      HAS gumbo_source_position	$.start_pos;
    }
    
#      typedef struct {
#   477   GumboVector /* GumboNode* */ children;
#   478 
#   480   GumboTag tag;
#   481 
#   483   GumboNamespaceEnum tag_namespace;
#   484 
#   491   GumboStringPiece original_tag;
#   492 
#   498   GumboStringPiece original_end_tag;
#   499 
#   501   GumboSourcePosition start_pos;
#   502 
#   504   GumboSourcePosition end_pos;
#   505 
#   510   GumboVector /* GumboAttribute* */ attributes;
#   511 } GumboElement;

  class gumbo_element_s is repr('CStruct') is export {
    HAS gumbo_vector_s		$.children;
    has int32			$.tag;
    has int32			$.tag_namespace;
    HAS gumbo_string_piece_s	$.original_tag;
    HAS gumbo_string_piece_s	$.original_end_tag;
    HAS gumbo_source_position	$.start_pos;
    HAS gumbo_source_position	$.end_pos;
    HAS gumbo_vector_s		$.attributes;
  }
  
#   struct GumboInternalNode {
#     GumboNodeType type;
#   
#     GumboNode* parent;
#   
#      size_t index_within_parent;
#    
#     GumboParseFlags parse_flags;
#    
#      union {
#        GumboDocument document;  // For GUMBO_NODE_DOCUMENT.
#        GumboElement element;    // For GUMBO_NODE_ELEMENT.
#        GumboText text;          // For everything else.
#      } v;
#    };
  class g_node_union is repr('CUnion') is export {
    HAS gumbo_document_s	$.document;
    HAS gumbo_element_s 	$.element;
    HAS gumbo_text_s		$.text;
  }
  
  class gumbo_node_s is repr('CStruct') is export {
    has int32		$.type;
    has gumbo_node_s	$.parent;
    has uint32		$.index_within_parent;
    has int32		$.parse_flags;
    HAS g_node_union	$.v;
  }
  
  class gumbo_vector_t is repr('CPointer') is export {};
  


  
#   typedef struct GumboInternalOutput {
#      GumboNode* document;
#    
#      GumboNode* root;
#    
#      GumboVector /* GumboError */ errors;
#    } GumboOutput;
#   
  class gumbo_output_s is repr('CStruct') is export {
    has gumbo_node_t $.document;
    has gumbo_node_t $.root;
    HAS gumbo_vector_s $.errors;
  }
  

  sub gumbo_parse(Str) is native('libgumbo') returns gumbo_output_t is export { * }
  sub gumbo_normalized_tagname(int32) is native('libgumbo') returns str is export { * }
  
  #this is only for debug purpose, show the size of the differents struct
  sub gumbo-type-size is export {
    for gumbo_output_s, gumbo_vector_s, gumbo_attribute_s, gumbo_document_s, gumbo_element_s, gumbo_node_s, gumbo_source_position, gumbo_string_piece_s, gumbo_text_s -> $type {
      say $type.perl~" : "~nativesizeof($type);
    }
    say nativesizeof(int32);
  }

}