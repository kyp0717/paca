import os
import websocket, json
import redis

ALPACA_API_KEY = os.getenv('APCA_API_KEY_ID')
ALPACA_SECRET_KEY = os.getenv('APCA_API_SECRET_KEY') 
REDIS_SERVICE = os.getenv('REDIS_SERVICE') 


r=redis.StrictRedis(host=REDIS_SERVICE)

def on_open(ws):
    print("opened")
    auth_data = {
        "action": "authenticate",
        "data": {"key_id": ALPACA_API_KEY, "secret_key": ALPACA_SECRET_KEY}
    }

    ws.send(json.dumps(auth_data))

    listen_message = {"action": "listen", "data": {"streams": ["AM.TSLA"]}}

    ws.send(json.dumps(listen_message))


def on_message(ws, message):
    print(message)
    price = message.symbol + "price"
    time = message.symbol + "time"


    r.set(message.symbol, message.price)
    r.set(message.symbol, message.timestamp)
    
def on_close(ws):
    print("closed connection")

socket = "wss://data.alpaca.markets/stream"

ws = websocket.WebSocketApp(socket, on_open=on_open, on_message=on_message, on_close=on_close)
ws.run_forever()
