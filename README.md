# Magento 1 / RealtimeDespatch Orderflow Env

- (Only do this once)
  Download the sample data packages from [Magento Release archives](https://magento.com/tech-resources/download) and copy to `sampledata` dir. 
  The files should be renamed to the following:
  - sampledata/magento-sample-data-1.9.1.0.tar.gz
  - sampledata/magento-sample-data-1.9.2.4.tar.gz

- (Only do this once per `MAGENTO_VERSION` and `ORDERFLOW_VERSION` combination)
  From the root of this project, build a demo store installer using the following command where `MAGENTO_VERSION` is the 
  version of Magento CE you'd like to install, and `ORDERFLOW_VERSION` is the extension version you wish to provision with.
  Remember to use a helpful tag so you can skip this step in future.
  ```
  docker build --build-arg MAGENTO_VERSION=1.9.4.1 -t orderflow-m1:1.9.4.1
  ```

- Create a target directory for your demo store
  ```
  mkdir /tmp/of_m1
  ```

- Install your demo store using the following command
  ```
  docker run --rm --interactive --volume /tmp/of_m1:/app orderflow-m1:1.9.4.1 /install.sh
  ```

- Boot up your environment.
  ```
  cd /tmp/of_m1 && docker-compose up
  ```

- Run the following command to install the sample db + setup a demo admin user.
  ```
  bin/post-install.sh
  ```

- Visit [http://localhost](http://localhost/admin) in your browser

- Access the admin at [http://localhost/admin](http://localhost/admin). 
  * User: `admin` 
  * Pass: `password123`
