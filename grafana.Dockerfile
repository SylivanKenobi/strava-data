FROM grafana/grafana:9.3.2

COPY assets/dashboards.yaml /etc/grafana/provisioning/dashboards/
COPY assets/datasources.yaml /etc/grafana/provisioning/datasources/
COPY assets/*.json /var/lib/grafana/dashboards/

ENV GF_INSTALL_PLUGINS="grafana-clock-panel,neocat-cal-heatmap-panel"

USER 1001
