"""Python Producer Main."""
import argparse

from financial_market import generate_trade_data
from kinesis_producer import KinesisProducer

from producer.utils import format_dict_to_json


def main():
    """Receive the arguments and produce data to the Kinesis stream."""
    parser = argparse.ArgumentParser(description="Kinesis Producer")
    parser.add_argument(
        "--stream_name",
        type=str,
        default="financial-stream",
        help="The name of the Kinesis stream",
    )
    parser.add_argument(
        "--region_name",
        type=str,
        default="us-east-1",
        help="The region name of the Kinesis stream",
    )
    parser.add_argument(
        "--max_records",
        type=int,
        default=10,
        help="The number of records to produce",
    )
    parser.add_argument(
        "--send_kinesis",
        type=bool,
        default=False,
        help="Send data to Kinesis",
    )
    args = parser.parse_args()

    schema = generate_trade_data(args.max_records)

    for data in schema.create():
        if args.send_kinesis:
            producer = KinesisProducer(args.stream_name, args.region_name)
            producer.send_message(
                format_dict_to_json(data), data["operation_id"]
            )
        else:
            print(format_dict_to_json(data))


if __name__ == "__main__":
    main()
