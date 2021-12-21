FROM grafana/grafana:8.3.3

COPY assets/dashboards.yaml /etc/grafana/provisioning/dashboards/
COPY assets/datasources.yaml /etc/grafana/provisioning/datasources/
COPY assets/*.json /var/lib/grafana/dashboards/

ENV GF_INSTALL_PLUGINS="grafana-clock-panel,neocat-cal-heatmap-panel"

USER 1001
