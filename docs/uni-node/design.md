## 🧩 Cluster Architecture (PlantUML)

```plantuml
@startuml

actor Dev as "Your Machine"

rectangle "VirtualBox" as VBox
rectangle "Weaveworks" as Weave

node "Load Balancer" as LB

node "Master 1" as M1 {
  component ETCD1
  label "M\nO"
}

node "Master 2" as M2 {
  component ETCD2
  label "M\nO"
}

node "Worker 1" as W1 {
  label "W\nO"
}

node "Worker 2" as W2 {
  label "W\nO"
}

Dev --> VBox
Dev --> Weave
Dev --> M1
Dev --> M2
Dev --> W1
Dev --> W2

LB --> M1
LB --> M2

@enduml
