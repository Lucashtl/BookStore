from django.urls import path, include
from rest_framework import routers 

from product import viewsets

router = routers.SimpleRouter()
router.register(r'products', viewsets.ProductViewSet, basename='product')
router.register(r'category', viewsets.CategoryViewSet, basename="category")

urlpatterns = [
    path('', include(router.urls)),
]