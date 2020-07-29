# rdk-xconf-multi-docker
The multiple dockerization of cassandra db, rdk xconf admin &amp; rdk xconf data service applications


###### How to generate the docker images

 - **sh xconf-builder.sh**
 
 This will start generating the images for cassandra , xconf-admin & xconf-dataservice. 
 After successful completion, we should get a message as shown below with 3 entries
 
 ```
 
Generated images
================
xconfdata_image              v1                  8e0e30461d27        Less than a second ago   1.11GB
xconfadmin_image             v1                  356082d89c76        About a minute ago       1.33GB
cassandra_image              v1                  053d681e9459        4 minutes ago            667MB

 ```
 
 ###### How to deploy the docker images
 
  - **docker-compose up -d** 
  (the -d option is given to run it in background)
  
  After successful creation of the containers, we should get a message as shown below
  
  ```
Creating network "multi_default" with the default driver
Creating cassandravm ... done
Creating xconfdatavm ... done
Creating xconfadminvm ... done
  ```

 ###### How to view the docker container instances
 
  - **docker container ps -a | grep vm**
  
  This command should ideally return 3 entries as shown below
  
  ```
d55db779513b   xconfadmin_image:v1   "/opt/xconfadmin_sta…"   1 minute ago   Up About a minute       0.0.0.0:9093->9093/tcp   xconfadminvm
1060ce25d113   xconfdata_image:v1    "/opt/xconfdata_star…"   3 minutes ago  Up 3 minutes (healthy)  0.0.0.0:9092->9092/tcp   xconfdatavm
a233634b56db   cassandra_image:v1    "/opt/cassandra_star…"   4 minutes ago  Up 4 minutes (healthy)  0.0.0.0:9042->9042/tcp,  cassandravm
                                                                                                     0.0.0.0:9160->9160/tcp   

  ```
  
  ## How to access the Xconf admin and data service instances
  (_http or https - change it accordingly_)
  
  ###### Xconf admin service
   
   - http://\<IP or HOSTNAME>:9093/admin/ux/
  
  This will open up a UI in the browser
  
    
  ###### Xconf data service
   
   - http://\<IP or HOSTNAME>:9092/loguploader/getSettings
  
  This will display a message as shown below in the browser 
  
  (_no need to worry by seeing that 'settings not found' message_)
  
  ```
  "<h2>404 NOT FOUND</h2><div>settings not found</div>"
  ```
  
  ------------
 
 :warning: :shield:
  
  If the services are not accessible, check the firewall or proxy on the VM where these dockers are installed.
  
  (_The deployed docker containers are already exposing the required ports. So no change required at that side_)
  
  
