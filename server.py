import asyncio
import datetime
import json
import time
import websockets
import ssl

CONNECTIONS = set()

async def hello(websocket, path):
    async for message in websocket:
        message = json.loads(message)
        data = {"name": message.get("name", ""), "message": message.get("message"), "time": time.mktime(datetime.datetime.utcnow().timetuple())}
        print(data)
        greeting = json.dumps(data)
        print(greeting)
        websockets.broadcast(CONNECTIONS, greeting)

async def main():
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain(certfile="cert.pem", keyfile="key.pem")

    async with websockets.serve(hello, "localhost", 8765, ssl=ssl_context):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())