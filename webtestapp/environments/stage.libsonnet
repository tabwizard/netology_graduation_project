
// this file has the baseline default parameters
{
  components: {
    web: {
    name: 'web',
    serviceName: 'httpd-service',
    image: 'tabwizard/nginxn:latest',
    replicas: 1,
    ports: {
      containerPortName: "http",
      containerPort: 80,
      containerPortProtocol: "TCP",
      port: 80,
      targetPort: 80,
      nodePort: 30080,
    },
    nodeSelector: {},
    },
  },
}
