
import os
import redis
import numpy

REDIS_SERVICE = os.getenv('REDIS_SERVICE') 

r=redis.StrictRedis(host=REDIS_SERVICE)
symbol = os.getenv('SYMBOL')

price = symbol + "price"
time = symbol + "time"
direction = symbol + 'direction'

price_list = []
time_list = []
while true:
    latest_price= r.get(price)
    latest_time= r.get(time)
    price_list = price_list.append(latest_price)
    time_list= time_list.append(latest_time)
    if len(price) == 6:
        price.pop(0)
        time.pop(0)

    result = numpy.polyfit(price,time)
    if result.rsquare > -0.0001 and result.rsquare < 0.0001:
        r.set(direction, 0)
    elif result.rsquare >= 0.0001:
        r.set(direction,1)
    elif result.rsquare <= -0.0001:
        r.set(direction,-1)
    sleep(15)


    












  









