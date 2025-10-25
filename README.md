# Setup
1. Clone this repo in `/myhome`
```bash
cd /myhome
git clone https://github.com/shgoshtasb/RunAI_misc
```

2. Create a `[workspace]_env file` for your workspace using `workspace_env` as an example

3. Set the default project and launch an ubuntu container in RunAI
```bash 
runai workspace submit [podname] -i ubuntu --gpu-portion-request .2 --cpu-memory-request 16G --large-shm --cpu-memory-limit 25G -e project=[project] --command -- "/myhome/RunAI_misc/scripts/setup-interactive.sh" 
```

4. Setup up kubectl for on the local machine and port-forward
```bash 
runai kc set
kubectl -n runai-[project]-[name] port-forward pod/[podname]-0-[0...6] 2222:22
```




