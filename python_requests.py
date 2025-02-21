import asyncio
import aiohttp
import time

async def fetch(session, url):
    async with session.get(url) as response:
        return await response.text()

async def stress_test(url, num_requests):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch(session, url) for _ in range(num_requests)]
        
        start_time = time.time()  # Start timing before requests
        await asyncio.gather(*tasks)
        end_time = time.time()  # End timing after all requests complete

        duration = end_time - start_time
        rps = num_requests / duration  # Requests per second

        print(f"Sent {num_requests} requests in {duration:.2f} seconds ({rps:.2f} requests/sec)")

asyncio.run(stress_test("http://example.com", 1000))

