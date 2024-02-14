# Hadoop HDFS Docker Setup with Telegraf Monitoring

This repository contains a Docker setup for running a Hadoop HDFS cluster with Telegraf for metrics collection and monitoring. The setup includes configuration files for Hadoop, a Dockerfile for building the Hadoop image, and a Telegraf configuration for sending metrics to Observe.

## Directory Structure

- `config/`: Contains Hadoop configuration files `core-site.xml` and `hdfs-site.xml`.
- `docker_entrypoint.sh`: The entrypoint script for the Docker container that starts Hadoop services.
- `Dockerfile`: Instructions for building the Hadoop Docker image.
- `telegraf.conf`: Telegraf configuration file for collecting metrics from Hadoop and sending them to Observe.

## Getting Started

### Configuring Telegraf

Before starting the container, make sure to update the `telegraf.conf` file with your specific `OBSERVE_CUSTOMER_ID` and `OBSERVE_INGEST_TOKEN`:

1. Open `telegraf.conf` in a text editor.
2. Locate the `[[outputs.http]]` section.
3. Replace `**OBSERVE_CUSTOMER_ID**` with your actual Observe customer ID.
4. Replace `**OBSERVE_INGEST_TOKEN**` with your actual Observe ingest token.

To get started with this setup, follow these steps:

1. Build the Hadoop Docker image:

`docker build -t hadoop-namenode-datanode .`

2. Create a local Docker Network: 

`docker network create hadoop`

3. Run the Hadoop container:

`
docker run -d
--name hadoop-namenode-datanode-test
--net hadoop
--net-alias namenode
--net-alias datanode
-p 9870:9870
-p 9820:9820
-p 9866:9866
-p 9867:9867
-p 9864:9864
-p 8778:8778
-p 8779:8779
-v $(pwd)/telegraf.conf:/etc/telegraf/telegraf.conf
hadoop-namenode-datanode
`

4. Confirm that the Hadoop services are running by checking the container logs:

`docker logs hadoop-namenode-datanode`


## Contributing

Feel free to contribute to this project by submitting pull requests or opening issues for any bugs or enhancements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.