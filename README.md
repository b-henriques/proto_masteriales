# Projet masteriales

Objectif: proof-ofconcept d'application communiquant avec vehicule electrique permettant d'adapter un itineraire en fonction de la charge/niveau d'autonomie actuelle

Plan:
1. Motivation/constats sur les solutions sur le marche actuel
2. Objectif
3. Recuperation de carte
4. Recuperation de donnees stations de recharge
5. Calcul itineraire
6. Algo proposé
7. Resultats

---
## Proof-of-concept

1 serveur en python, flask permettant de recuperer les donnees sur les stations de recharge et de caulculer l'itineraire
1 application mobile simulant la connexion avec la batterie et le serveur

---
TODO: (serveur) telechargement des donnees si non presentes <br>
TODO: (serveur) Actualisation des donnees des stations de recharge <br>
TODO: (client) buffer stations de recharge(voir figure) <br>
TODO: (client) Simulation de batterie/vehicule <br>
TODO: (client) actualisation iteneraire en fonction du temps ecoule, niveua de batterie, eventuel detour <br>
TODO: (client) indications navigation: nom rue actuelle, sortir a droite,rondpoint... <br>

---
DONE: affichage carte openstreetmap <br>
DONE: serveur calcul distances, passage distance kms vers lat,lon, boundingbox  <br>
DONE: serveur flask, requete stations de recharge in range <br>
DONE: affichage des stations de recharge <br>
DONE: serveur flask, communication avec ign geoservices <br>
DONE: serveur flask, requete itineraire simple  <br>
DONE: serveur flask requete itineraire en passant par une station de  recharge(algo proposé)  <br>
DONE: Affichage du trajet <br>

---
### Test

Http: Connection closed while receiving data. <br>
https://github.com/flutter/flutter/issues/86772 <br>
Un probleme de communication est present lorsqu'on utilise un emulateur android. Pensez a utiliser un vrai appareil pour tester le calcul d'itineraire.

Vu le volume du fichier contennant les donnees sur les stations de recharge, il n'est pas present sur ce repo, pensez y a le telecharger et le mettre dans le serveur, dossier ressources (il faut peut etre changer le nom du fichier dans le code? tant qu'on a pas implemente telechargement et actualisation automatique).
