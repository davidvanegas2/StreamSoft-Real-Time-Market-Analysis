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
from datetime import datetime


def simulate_stock_prices() -> dict:
    """Simulate stock prices with random values.

    The values simulated are:
    - open
    - high
    - low
    - close
    - current

    The high value is always greater than the open value.
    The low value is always smaller than the open value.

    Returns
    -------
    dict
        The simulated stock prices
    """
    open_price = random.uniform(100, 200)
    high_price = open_price + random.uniform(0, 10)
    low_price = open_price - random.uniform(0, 10)
    close_price = random.uniform(low_price, high_price)
    current = close_price + random.uniform(-1, 1)

    return {
        "open": round(open_price, 2),
        "high": round(high_price, 2),
        "low": round(low_price, 2),
        "close": round(close_price, 2),
        "current": round(current, 2),
    }


def get_stock_data(symbol: str) -> dict:
    """Get the stock data for a given symbol.

    All the data will be simulated.

    Parameters
    ----------
    symbol: str
        The symbol of the stock

    Returns
    -------
    dict
        The stock data
    """
    metadata = {
        "symbol": symbol,
        "timestamp": datetime.now().isoformat(),
        "exchange": "NASDAQ",
        "currency": "USD",
    }
    prices = simulate_stock_prices()
    return metadata | prices
