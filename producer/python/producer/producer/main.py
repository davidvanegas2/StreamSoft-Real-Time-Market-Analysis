"""Python Producer Main."""
import argparse

from financial_market import generate_trade_data
from kinesis_producer import KinesisProducer

from producer.utils import format_dict_to_json, get_average_size


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
    parser.add_argument(
        "--get_average_record_size",
        type=bool,
        default=False,
        help="Get the average size of the record",
    )
    args = parser.parse_args()
    records = []

    schema = generate_trade_data(args.max_records)

    for data in schema.create():
        if args.send_kinesis:
            producer = KinesisProducer(args.stream_name, args.region_name)
            producer.send_message(format_dict_to_json(data), data["exchange"])
        else:
            json_data = format_dict_to_json(data)
            records.append(json_data)
            print(json_data, data["exchange"])

    if args.get_average_record_size:
        print(get_average_size(records))


if __name__ == "__main__":
    main()
