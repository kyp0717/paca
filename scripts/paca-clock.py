import alpaca_trade_api as tradeapi
import redis 
import time

def gettime():
    api = tradeapi.REST()
    time = api.get_clock()
    # print(time)



r = redis.StrictRedis(host='localhost', port=6379, db=0)

r.lpush('myqueue','myelement')


# for i in range(1,100):
#     gettime()
#     time.sleep(10)

