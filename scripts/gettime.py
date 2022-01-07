import alpaca_trade_api as tradeapi
import time

def gettime():
    api = tradeapi.REST()
    time = api.get_clock()
    print(time)


for i in range(1,100):
    gettime()
    time.sleep(10)

