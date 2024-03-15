kubectl create -f https://download.elastic.co/downloads/eck/2.6.1/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.6.1/operator.yaml
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster cm-tf-eks-cluster --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole
eksctl create addon --name aws-ebs-csi-driver --cluster cm-tf-eks-cluster --service-account-role-arn arn:aws:iam::412032026508:role/AmazonEKS_EBS_CSI_DriverRole --force
kubectl apply -f elasticsearch.yaml
kubectl port-forward service/quickstart-es-http 9200
kubectl apply -f kibana.yaml
kubectl port-forward service/quickstart-kb-http 5601
kubectl apply -f logstash-config.yaml 
kubectl apply -f logstash.yaml
kubectl apply -f filebeat-config.yaml
kubectl apply -f filebeat.yaml
kubectl apply -f filebeat-authorization.yaml
kubectl apply -f filebeat-daemonset.yaml