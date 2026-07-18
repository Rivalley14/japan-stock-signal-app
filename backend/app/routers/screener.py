from fastapi import APIRouter

from app.services import screener

router = APIRouter(prefix="/screener", tags=["screener"])


@router.get("/crosses")
def get_crosses():
    return screener.get_cross_screening()


@router.post("/refresh")
def refresh_crosses():
    return screener.refresh_cross_screening()
