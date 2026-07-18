from contextlib import asynccontextmanager

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI

from app.routers import screener, stocks
from app.services import screener as screener_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = BackgroundScheduler()
    scheduler.add_job(screener_service.refresh_cross_screening, "interval", hours=6)
    scheduler.start()
    scheduler.add_job(screener_service.refresh_cross_screening)
    yield
    scheduler.shutdown(wait=False)


app = FastAPI(title="Japan Stock Analysis API", lifespan=lifespan)
app.include_router(stocks.router)
app.include_router(screener.router)


@app.get("/health")
def health():
    return {"status": "ok"}
