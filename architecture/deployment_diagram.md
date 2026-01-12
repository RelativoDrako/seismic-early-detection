
Deployment Diagram
mermaid
flowchart TB
    subgraph Site
        Sensor --> EdgeNode
    end
    EdgeNode --> CentralPlatform
