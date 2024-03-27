"""Python file which contains class FinancialMarket.

This class is responsible for handling the financial market data
simulating what would be done in a real-world scenario.


Methods
-------
send_request(url: str) -> dict
    Send a request to the Alpha Vantage API and return the response.

get_stock_data(symbol: str, output_size: str = "compact") -> dict
    Get the stock data for a given symbol.

"""
import random

from mimesis import Field, Schema


def define_schema():
    """Define the schema for the trade data.

    Returns
    -------
    dict
        The schema for the trade data
    """
    field = Field()
    return {
        "operation_id": field("uuid"),
        "person_name": field("person.full_name"),
        "symbol": field("finance.stock_ticker"),
        "timestamp": field(
            "datetime.formatted_datetime", fmt="%Y-%m-%d %H:%M:%S"
        ),
        "exchange": field("finance.stock_exchange"),
        "currency": "USD",
        "price": round(field("finance.price"), 2),
        "operation": random.choice(["purchase", "sale"]),
    }


def generate_trade_data(n: int) -> Schema:
    """Generate trade data.

    Parameters
    ----------
    n: int
        The number of trade data to generate

    Returns
    -------
    list
        A list of trade data
    """
    return Schema(schema=define_schema, iterations=n)
