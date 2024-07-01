{{ define "webappImage" }}
- name: webapp
  image: {{ .Values.dockerRepoName }}/k8s-fleetman-helm-demo:v1.0.0{{ if eq .Values.development true }}-dev{{ end }}
{{ end }}