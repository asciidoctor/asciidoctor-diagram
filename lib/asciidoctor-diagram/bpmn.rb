require 'asciidoctor/extensions'
require_relative 'bpmn/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::BpmnBlockProcessor, :bpmn
  block_macro Asciidoctor::Diagram::BpmnBlockMacroProcessor, :bpmn
end
