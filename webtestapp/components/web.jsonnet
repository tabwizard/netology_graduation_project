local p = import '../params.libsonnet';
local params = p.components.web;
local env = {
  namespace: std.extVar('qbec.io/env'),
};

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: { app: params.name, },
      name: params.name,
    },
    spec: {
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: { app: params.name },
        },
        spec: {
          containers: [
            {
              name: 'nginxn',
              image: params.image,
              ports: [
                {
                  name: params.ports.containerPortName,
                  containerPort: params.ports.containerPort,
                  protocol: params.ports.containerPortProtocol,
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: params.serviceName,
    },
    spec: {
      selector: {
        app: params.name,
      },
      ports: [
        {
          name: params.ports.containerPortName,
          port: params.ports.port,
          protocol: params.ports.containerPortProtocol,
          targetPort: params.ports.targetPort,
          nodePort: params.ports.nodePort,
        },
      ],
      type: 'NodePort',
    },
  },
] 
