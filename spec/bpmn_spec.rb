require_relative 'test_helper'

BPNM_CODE = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<bpmn:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" xmlns:di="http://www.omg.org/spec/DD/20100524/DI" id="Definitions_0zt4mn9" targetNamespace="http://bpmn.io/schema/bpmn" exporter="bpmn-js (https://demo.bpmn.io)" exporterVersion="5.1.2">
  <bpmn:process id="Process_081h9u7" isExecutable="false">
    <bpmn:startEvent id="StartEvent_00w25dz" name="Start">
      <bpmn:outgoing>SequenceFlow_11u0n1f</bpmn:outgoing>
    </bpmn:startEvent>
    <bpmn:task id="Task_0yx8j7s" name="Task">
      <bpmn:incoming>SequenceFlow_11u0n1f</bpmn:incoming>
      <bpmn:outgoing>SequenceFlow_104th5x</bpmn:outgoing>
    </bpmn:task>
    <bpmn:sequenceFlow id="SequenceFlow_11u0n1f" sourceRef="StartEvent_00w25dz" targetRef="Task_0yx8j7s" />
    <bpmn:endEvent id="EndEvent_0jxehtp" name="End">
      <bpmn:incoming>SequenceFlow_104th5x</bpmn:incoming>
    </bpmn:endEvent>
    <bpmn:sequenceFlow id="SequenceFlow_104th5x" sourceRef="Task_0yx8j7s" targetRef="EndEvent_0jxehtp" />
  </bpmn:process>
  <bpmndi:BPMNDiagram id="BPMNDiagram_1">
    <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_081h9u7">
      <bpmndi:BPMNShape id="_BPMNShape_StartEvent_2" bpmnElement="StartEvent_00w25dz">
        <dc:Bounds x="156" y="81" width="36" height="36" />
        <bpmndi:BPMNLabel>
          <dc:Bounds x="162" y="124" width="24" height="14" />
        </bpmndi:BPMNLabel>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_0yx8j7s_di" bpmnElement="Task_0yx8j7s">
        <dc:Bounds x="250" y="59" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge id="SequenceFlow_11u0n1f_di" bpmnElement="SequenceFlow_11u0n1f">
        <di:waypoint x="192" y="99" />
        <di:waypoint x="250" y="99" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNShape id="EndEvent_0jxehtp_di" bpmnElement="EndEvent_0jxehtp">
        <dc:Bounds x="412" y="81" width="36" height="36" />
        <bpmndi:BPMNLabel>
          <dc:Bounds x="420" y="124" width="20" height="14" />
        </bpmndi:BPMNLabel>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge id="SequenceFlow_104th5x_di" bpmnElement="SequenceFlow_104th5x">
        <di:waypoint x="350" y="99" />
        <di:waypoint x="412" y="99" />
      </bpmndi:BPMNEdge>
    </bpmndi:BPMNPlane>
  </bpmndi:BPMNDiagram>
</bpmn:definitions>
EOF

describe Asciidoctor::Diagram::BpmnBlockMacroProcessor do
  include_examples "block_macro", :bpmn, BPNM_CODE, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::BpmnBlockProcessor do
  include_examples "block", :bpmn, BPNM_CODE, [:png, :svg, :pdf]
end