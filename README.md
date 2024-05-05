# Custom Autoscaling Kubernetes Resources using Keda
---
1. Modify the `keda-vmsvc.yaml` as per the following - 
 - Change the ConfigMap to add your custom resources that need to be scaled. 
 - For resources that need unique naming, you can use the `${tempvar}` variable. This variable is substituted by the last 5 characters of the pod that will be responsible for scaling the resource. 
 - Modify the Role to allow the ServiceAccount to perform CRUD operation on these resources.

2. Deploy the `keda-vmsvc.yaml` in your namespace. The deployment started with `replicas: 0`. 

3. Deploy your KEDA scaledobject in the namespace. Two examples are provided - one that scales based on a CRON trigger and another that is based on a Postgres trigger. 

4. Notice the scale out and scale in operations based on Keda triggers. 

---

### 1. Deploy the pods that will be responsbile for triggering the scaling

```bash
$ kubectl apply -f keda-vmsvc.yaml -n demo1
serviceaccount/keda-vmsvc-sa created
role.rbac.authorization.k8s.io/keda-vmsvc-role created
rolebinding.rbac.authorization.k8s.io/keda-vmsvc-rolebinding created
configmap/deployment-manifest created
deployment.apps/keda-vmsvc-deployment created
```

```bash
$ kubectl get deploy -n demo1
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
keda-vmsvc-deployment   0/0     0            0           17s
```

### 2. Deploy the KEDA ScaledObject

```bash
$ kubectl apply -f keda-scaledobject-cron.yaml -n demo1
scaledobject.keda.sh/keda-vmsvc-scaledobject-cron created
```

```bash
$ kubectl get scaledobject.keda.sh  -n demo1
NAME                           SCALETARGETKIND      SCALETARGETNAME         MIN   MAX   TRIGGERS   AUTHENTICATION   READY   ACTIVE   FALLBACK   PAUSED    AGE
keda-vmsvc-scaledobject-cron   apps/v1.Deployment   keda-vmsvc-deployment   0           cron                        True    True     Unknown    Unknown   8s
```

### 3. Observe the scaling that is triggered by the pods replicas that were deployed in Step 1.  

```bash
$ kubectl pods -n demo1
NAME                                     READY   STATUS              RESTARTS   AGE
...
keda-vmsvc-deployment-7744c9bbc6-hw56h   0/1     Pending             0          0s
keda-vmsvc-deployment-7744c9bbc6-mrvfp   1/1     Running             0          30s
keda-vmsvc-deployment-7744c9bbc6-qd4ps   0/1     ContainerCreating   0          15s
keda-vmsvc-deployment-7744c9bbc6-ttjdq   0/1     Pending             0          15s
keda-vmsvc-deployment-7744c9bbc6-wxtdh   0/1     Pending             0          15s
...
```
---

```bash
$ kubectl get vm -n demo1
NAME                                                             POWER-STATE   AGE
...
vmware-hw56h-jumpbox                                             poweredOn     2m29s
vmware-mrvfp-jumpbox                                             poweredOn     3m2s
vmware-qd4ps-jumpbox                                             poweredOn     2m47s
vmware-ttjdq-jumpbox                                             poweredOn     2m36s
vmware-wxtdh-jumpbox                                             poweredOn     2m43s
...

$ kubectl get svc -n demo1
NAME                                          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                                          AGE
...
vmware-hw56h-jumpbox                          LoadBalancer   10.96.1.191   10.220.8.14   22:30400/TCP,443:30963/TCP                       2m41s
vmware-mrvfp-jumpbox                          LoadBalancer   10.96.0.197   10.220.8.10   22:31326/TCP,443:30708/TCP                       3m14s
vmware-qd4ps-jumpbox                          LoadBalancer   10.96.1.18    10.220.8.11   22:30167/TCP,443:32158/TCP                       2m59s
vmware-ttjdq-jumpbox                          LoadBalancer   10.96.1.121   10.220.8.13   22:30065/TCP,443:32194/TCP                       2m48s
vmware-wxtdh-jumpbox                          LoadBalancer   10.96.0.195   10.220.8.12   22:30109/TCP,443:32054/TCP                       2m55s
...

$ kubectl get cm -n demo1
NAME                                   DATA   AGE
...
jumpbox-hw56h-configmap                3      2m52s
jumpbox-mrvfp-configmap                3      3m25s
jumpbox-qd4ps-configmap                3      3m10s
jumpbox-ttjdq-configmap                3      2m59s
jumpbox-wxtdh-configmap                3      3m6s
...

$ kubectl get pvc -n demo1
NAME                                                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
...
jumpbox-hw56h-pvc                                                Bound    pvc-5cf1b0fc-416b-4957-b732-5078e50e1c29   2Gi        RWO            vc01cl01-t0compute   3m1s
jumpbox-mrvfp-pvc                                                Bound    pvc-ac722f11-b396-4c6d-b1d1-8198566dc51d   2Gi        RWO            vc01cl01-t0compute   3m34s
jumpbox-qd4ps-pvc                                                Bound    pvc-36b56491-5f2d-473b-9c1c-e682f43d6572   2Gi        RWO            vc01cl01-t0compute   3m19s
jumpbox-ttjdq-pvc                                                Bound    pvc-6571e6d5-e5af-4dd5-a759-6787ff09653e   2Gi        RWO            vc01cl01-t0compute   3m8s
jumpbox-wxtdh-pvc                                                Bound    pvc-f2f77d7b-de7b-4962-9d81-2ab358623f3f   2Gi        RWO            vc01cl01-t0compute   3m15s
...
```
