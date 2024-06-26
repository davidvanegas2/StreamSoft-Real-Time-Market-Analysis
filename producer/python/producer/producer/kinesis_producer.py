"""Python file which contains class KinesisProducer.

This class is responsible for producing data to a Kinesis stream.
The data is fetched from the financial market through FinancialMarket class.

Attributes
----------
stream_name: str
    The name of the Kinesis stream
partition_key: str
    The partition key for the Kinesis stream
financial_market: FinancialMarket
    An instance of the FinancialMarket class

Methods
-------
produce_data()
    Produce data to the Kinesis stream

"""
import uuid

import boto3


class KinesisProducer:
    """Class to produce data to a Kinesis stream."""

    def __init__(self, stream_name: str, region_name: str):
        """Initialize the KinesisProducer class.

        Parameters
        ----------
        stream_name: str
            The name of the Kinesis stream
        region_name: str
            The region name of the Kinesis stream
        """
        self.stream_name = stream_name
        self.region_name = region_name
        self.client = self._connect_kinesis()

    def _connect_kinesis(self):
        """Connect to the Kinesis stream."""
        return boto3.client("kinesis", region_name=self.region_name)

    def send_message(
        self, message: str, partition_key: str = str(uuid.uuid4())
    ) -> None:
        """Send a message to the Kinesis stream.

        Parameters
        ----------
        message: str
            The message to send to the Kinesis stream
        partition_key: str
            The partition key for the Kinesis stream
        """
        self.client.put_record(
            StreamName=self.stream_name,
            Data=message,
            PartitionKey=partition_key,
        )
