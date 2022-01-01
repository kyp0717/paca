import alpaca_trade_api as tradeapi

api = tradeapi.REST()
time = api.get_clock()
print(time)
