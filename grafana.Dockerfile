FROM grafana/grafana:latest

COPY assets/dashboards.yaml /etc/grafana/provisioning/dashboards/
COPY assets/datasources.yaml /etc/grafana/provisioning/datasources/
COPY assets/*.json /var/lib/grafana/dashboards/

USER 1001
