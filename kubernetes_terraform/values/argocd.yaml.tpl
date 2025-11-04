extraObjects:
%{ for name, project in extra_projects ~}
  - apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: ${ name }
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      description: ${ project.description }
      sourceRepos:
%{ for sr in toset(project.source_repos) ~}
      - ${ sr }
%{ endfor }
      destinations:
%{ for dest in toset(project.destinations) ~}
      - namespace: ${ dest.namespace }
        server: ${ dest.server }
%{ endfor }
      clusterResourceWhitelist:
%{ for crw in toset(project.cluster_resource_whitelist) ~}
      - group: ${ crw.group }
        kind: ${ crw.kind }
%{ endfor }
      namespaceResourceBlacklist: []
      namespaceResourceWhitelist:
%{ for nrw in toset(project.namespace_resource_whitelist) ~}
      - group: ${ nrw.group }
        kind: ${ nrw.kind }
%{ endfor }
      syncWindows:
%{ for sw in toset(project.sync_windows) ~}
      - kind: ${ sw.kind }
        schedule: ${ sw.schedule }
        duration: ${ sw.duration }
        applications:
%{ for app in toset(sw.applications) ~}
        - ${ app }
%{ endfor }
        manualSync: ${ sw.manual_sync }
%{ endfor }
%{ endfor }
%{ for name, app in extra_applications ~}
  - apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${ name }
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: ${ app.project }
      source:
        repoURL: ${ app.repo_url }
        targetRevision: ${ app.target_revision }
        path: ${ app.path }
        helm:
          releaseName: ${ name }
          valueFiles:
            - values.yaml
%{ for vf in app.value_files ~}
            - ${ vf }
%{ endfor }
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
%{ endfor }
