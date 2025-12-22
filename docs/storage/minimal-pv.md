kind: PersistentVolume
metadata:
  name: black-pv-cka
spec:
  capacity:
    storage: 50Mi
  hostPath:
    path: /opt/black-pv-cka
  accessModes:
  - ReadWriteOnce