"""Python Producer Main."""
from kinesis_producer import KinesisProducer

if __name__ == "__main__":
    producer = KinesisProducer("financial-stream", "us-east-1")
    producer.produce_data()
