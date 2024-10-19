from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Location
from django.contrib.auth.models import User
from .serializers import LocationSerializer

@api_view(['POST'])
def receive_location_data(request):
    user = request.user  # Preuzima trenutnog korisnika
    data = request.data
    
    # Proveri da li su latitude i longitude prisutni u podacima
    if 'latitude' not in data or 'longitude' not in data:
        return Response({"status": "error", "message": "Nedostaju podaci o lokaciji."}, status=400)

    location = Location(user=user, latitude=data['latitude'], longitude=data['longitude'])
    location.save()

    # Koristi serializer za vraćanje podataka
    serializer = LocationSerializer(location)

    print("Primljeni podaci o lokaciji:", data)
    return Response({"status": "success", "location_data": serializer.data})

@api_view(['GET'])
def users_nearby(request):
    user_id = request.GET.get('user_id')  # Preuzmi ID korisnika iz GET parametara
    radius = 50  # Definiši radijus od 50 metara

    if not user_id:
        return Response({"status": "error", "message": "Nedostaje user_id."}, status=400)

    try:
        user = User.objects.get(id=user_id)
        user_location = Location.objects.filter(user=user).order_by('-timestamp').first()

        if user_location:
            nearby_users = Location.objects.raw(
                '''
                SELECT id, user_id, latitude, longitude, timestamp
                FROM m33t_location
                WHERE (ABS(latitude - %s) <= 0.00045 AND ABS(longitude - %s) <= 0.00045)
                AND user_id != %s
                ''', [user_location.latitude, user_location.longitude, user_id]
            )

            nearby_user_list = [
                {
                    'user_id': loc.user_id,
                    'latitude': loc.latitude,
                    'longitude': loc.longitude,
                    'timestamp': loc.timestamp
                }
                for loc in nearby_users
            ]

            return Response({"status": "success", "nearby_users": nearby_user_list})
        else:
            return Response({"status": "error", "message": "Nema dostupnih podataka o lokaciji za korisnika."})

    except User.DoesNotExist:
        return Response({"status": "error", "message": "Korisnik nije pronađen!"}, status=404)
