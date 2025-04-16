from rest_framework.viewsets import ModelViewSet

from order.models import Order
from order.serializers import OrderSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.authentication import SessionAuthentication, BasicAuthentication, TokenAuthentication


class OrderViewSet(ModelViewSet):
    authentication_class = [SessionAuthentication, BasicAuthentication, TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer
    queryset = Order.objects.all().order_by('id')
    
    class Meta:
        ordering = ['-id']