# m33t/urls.py

from django.urls import path
from .views import receive_location_data, users_nearby

urlpatterns = [
    path('api/location/', receive_location_data, name='receive_location_data'),
    path('api/user_locations/', users_nearby, name='users_nearby'),
]
