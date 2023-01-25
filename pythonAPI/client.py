import requests



response_API = requests.get('http://127.0.0.1:5000/itineraire/position=48.6158982,2.42770525&destination=48.709696,2.167326&range=10.0')
print(response_API.json())