#!/usr/bin/env python3

from marketdata import *

def main():

    logger=OALog()

    # Create ticker objects from tickers in WsbBalancer
    ticker_oags = {
        ticker: OAG_Ticker(logger=logger).db.create({
            'ticker' : ticker,
        })[0] for ticker in OAG_WsbBalancer.streams
    }

    # Assign tickers to WsbBalancer
    wsb_index = OAG_WsbBalancer(logger=logger)
    for ticker in OAG_WsbBalancer.streams:
        setattr(wsb_index, ticker, ticker_oags[ticker])

    # Start price retrieval for each ticker
    glet_arrays = [getattr(wsb_index, ticker, None).start_price_monitor() for ticker in OAG_WsbBalancer.streams]
    glets = [glet for array in glet_arrays for glet in array]
    gevent.joinall(glets)

if __name__ == '__main__':
    main()
