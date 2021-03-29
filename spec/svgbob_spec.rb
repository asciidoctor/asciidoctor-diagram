require_relative 'test_helper'

SVGBOB_CODE = <<-eos
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

describe Asciidoctor::Diagram::SvgBobBlockMacroProcessor do
  include_examples "block_macro", :svgbob, SVGBOB_CODE, [:svg]
end

describe Asciidoctor::Diagram::SvgBobBlockProcessor do
  include_examples "block", :svgbob, SVGBOB_CODE, [:svg]
end
