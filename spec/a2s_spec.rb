require_relative 'test_helper_methods'

A2S_CODE = <<-eos
                      .--.            .---.  .---. .---.  .---.    .---.  .---. 
                      |  |   OS API   '---'  '---' '---'  '---'    '---'  '---' 
                      v  |              |      |     |      |        |      |   
             .-. .-. .-. |              v      v     |      v        |      v   
         .-->'-' '-' '-' |            .------------. | .-----------. |  .-----. 
         |     \\  |  /   |            | Filesystem | | | Scheduler | |  | MMU | 
         |      v . v    |            '------------' | '-----------' |  '-----' 
         '_______/ \\_____|                   |       |      |        |          
                 \\ /                         v       |      |        v          
                  |     ____              .----.     |      |    .---------.    
                  '--> /___/              | IO |<----'      |    | Network |    
                                          '----'            |    '---------'    
                                             |              |         |         
                                             v              v         v         
                                      .---------------------------------------. 
                                      |                  HAL                  | 
                                      '---------------------------------------'
eos

describe Asciidoctor::Diagram::AsciiToSvgInlineMacroProcessor do
  include_examples "inline_macro", :a2s, A2S_CODE, [:svg]
end

describe Asciidoctor::Diagram::AsciiToSvgBlockMacroProcessor do
  include_examples "block_macro", :a2s, A2S_CODE, [:svg, :txt]
end

describe Asciidoctor::Diagram::AsciiToSvgBlockProcessor do
  include_examples "block", :svgbob, A2S_CODE, [:svg, :txt]
end
