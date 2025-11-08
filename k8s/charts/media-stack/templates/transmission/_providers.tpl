{{- define "transmission.provider-config" -}}
- name: OPENVPN_PROVIDER
  value: {{ $.Values.transmission.provider.name | squote }}
{{- if $.Values.transmission.provider.user.extraSecret }}
- name: OPENVPN_USERNAME
  valueFrom:
    secretKeyRef:
      name:  {{ $.Values.transmission.provider.user.extraSecret.name }}
      key:  {{ $.Values.transmission.provider.user.extraSecret.userKey }}
- name: OPENVPN_PASSWORD
  valueFrom:
    secretKeyRef:
      name:  {{ $.Values.transmission.provider.user.extraSecret.name }}
      key:  {{ $.Values.transmission.provider.user.extraSecret.passwordKey }}
{{- else if $.Values.transmission.provider.user.externalSecret }}
- name: OPENVPN_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "transmission.fullname" . | printf "vpn-credentials-%s" }}
      key: user
- name: OPENVPN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "transmission.fullname" . | printf "vpn-credentials-%s" }}
      key: password
{{- else }}
- name: OPENVPN_USERNAME
  value: {{ $.Values.transmission.provider.user.name | squote }}
- name: OPENVPN_PASSWORD
  value: {{ $.Values.transmission.provider.user.password | squote }}
{{- end }}
{{- if eq $.Values.transmission.provider.name "custom" }}
- name: OPENVPN_CONFIG
  value: {{ $.Values.transmission.provider.endpoint | squote }}
{{- end }}
{{- with $.Values.transmission.provider.extraOpts }}
- name: OPENVPN_OPTS
  value: {{ . | squote }}
{{- end }}
- name: LOCAL_NETWORK
  value: {{ $.Values.transmission.provider.localNetwork | squote }}
- name: CREATE_TUN_DEVICE
  value: {{ $.Values.transmission.provider.create_tun_device | default true | squote }}
- name: PEER_DNS
  value: {{ $.Values.transmission.peer_dns | default true | squote }}
- name: PEER_DNS_PIN_ROUTES
  value: {{ $.Values.transmission.peer_dns_pin_routes | default true | squote }}
{{- if eq $.Values.transmission.provider.name "nordvpn" }}
- name: NORDVPN_COUNTRY
  value: {{ $.Values.transmission.provider.endpoint | squote }}
- name: NORDVPN_CATEGORY
  value: {{ $.Values.transmission.provider.category | squote }}
- name: NORDVPN_PROTOCOL
  value: {{ $.Values.transmission.provider.protocol | squote }}
{{- end }}
{{- end }}

{{- define "transmission.firewall-config" }}
- name: ENABLE_UFW
  value: {{ $.Values.transmission.firewall.enable  | squote}}
- name: UFW_ALLOW_GW_NET
  value: {{ $.Values.transmission.firewall.allowGatewayNetwork | default false | squote }}
- name: UFW_EXTRA_PORTS
  value: {{ $.Values.transmission.firewall.extraPorts | squote }}
- name: UFW_DISABLE_IPTABLES_REJECT
  values {{ $.Values.transmission.firewall.disableReject | squote }}
{{- end -}}

{{- define "transmission.rpc-config" -}}
- name: TRANSMISSION_RPC_ENABLED
  value: {{ $.Values.transmission.rpc.enabled | squote }}
- name: TRANSMISSION_RPC_AUTH_REQUIRED
  value: {{ $.Values.transmission.rpc.auth_required | squote }}
- name: TRANSMISSION_RPC_BIND_ADDRESS
  value: '0.0.0.0'
- name: TRANSMISSION_RPC_PORT
  value: '9091'
{{- if $.Values.transmission.rpc.user.extraSecret }}
- name: TRANSMISSION_RPC_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.transmission.rpc.user.extraSecret.name }}
      key: {{ $.Values.transmission.rpc.user.extraSecret.userKey }}
- name: TRANSMISSION_RPC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.transmission.rpc.user.extraSecret.name }}
      key: {{ $.Values.transmission.rpc.user.extraSecret.passwordKey }}
{{- else if $.Values.transmission.rpc.user.externalSecret }}
- name: TRANSMISSION_RPC_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "transmission.fullname" . | printf "rpc-credentials-%s" }}
      key: user
- name: TRANSMISSION_RPC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "transmission.fullname" . | printf "rpc-credentials-%s" }}
      key: password
{{- else }}
- name: TRANSMISSION_RPC_USERNAME
  value: {{ $.Values.transmission.rpc.user.name }}
- name: TRANSMISSION_RPC_PASSWORD
  value: {{ $.Values.transmission.rpc.user.password }}
{{- end }}
{{- if deepEqual $.Values.transmission.rpc.whitelist (list) }}
- name: TRANSMISSION_RPC_WHITELIST_ENABLED
  value: "false"
{{- else }}
- name: TRANSMISSION_RPC_WHITELIST_ENABLED
  value: "true"
- name:  TRANSMISSION_RPC_WHITELIST
  value: {{ join "," $.Values.transmission.rpc.whitelist | squote }}
{{- end }}
{{- end }}