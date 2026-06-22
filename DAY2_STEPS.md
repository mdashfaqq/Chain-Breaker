\# M2 Day 2 Deployment Procedure



\## Objective



Deploy Wazuh 4.12.0 successfully and access the dashboard.



\---



\## Step 1: Prepare a Fresh Environment



\* Created a fresh working directory.

\* Cloned the Wazuh Docker repository.

\* Switched to tag `v4.12.0`.



```powershell

git checkout v4.12.0

```



\---



\## Step 2: Verify Single Node Files



Verified that the following files existed:



\* docker-compose.yml

\* generate-indexer-certs.yml

\* config/

\* certs.yml



\---



\## Step 3: Generate SSL Certificates



Moved into the single-node directory and generated certificates.



```powershell

cd single-node



docker compose -f generate-indexer-certs.yml run --rm generator

```



Verified generated files:



\* root-ca.pem

\* admin.pem

\* admin-key.pem

\* wazuh.indexer.pem

\* wazuh.indexer-key.pem

\* wazuh.manager.pem

\* wazuh.dashboard.pem



\---



\## Step 4: Clean Previous Deployment



Stopped containers and removed old volumes.



```powershell

docker compose down -v

docker volume prune -f

```



\---



\## Step 5: Deploy Wazuh Stack



Started all services.



```powershell

docker compose up -d

```



Services started:



\* Wazuh Indexer

\* Wazuh Manager

\* Wazuh Dashboard



\---



\## Step 6: Verify Container Status



Checked running containers.



```powershell

docker ps

```



Verified:



\* single-node-wazuh.indexer-1

\* single-node-wazuh.manager-1

\* single-node-wazuh.dashboard-1



All containers were running successfully.



\---



\## Step 7: Access Dashboard



Opened:



```

https://localhost

```



Logged in with:



Username:



```

admin

```



Password:



```

SecretPassword

```



\---



\## Step 8: Verify Wazuh Modules



Successfully explored:



\* Dashboard Overview

\* Threat Hunting

\* Vulnerability Detection

\* File Integrity Monitoring

\* MITRE ATT\&CK



Confirmed alerts were being indexed.



\---



\## Step 9: Capture Evidence



Collected screenshots for:



\* Dashboard Overview

\* Threat Hunting

\* Docker containers

\* Generated certificates



\---



\## Status



Day 2 deployment completed successfully.



A functional Wazuh SIEM environment was deployed and verified.



