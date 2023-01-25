from dataclasses import dataclass
import json
import dist


class StationRechargeProvider:
    """
    """

    def __init__(self):
        self.stationsRechargeData = {}

        with (open('Ressources\consolidation-etalab-schema-irve-v-2.1.0-20230120.json')) as file:
            # load data
            data = json.load(file)
            # store data
            for station in data['features']:
                stationdata = StationRecharge(**station['properties'])
                if stationdata.coordonneesXY not in self.stationsRechargeData:
                    self.stationsRechargeData[stationdata.coordonneesXY] = stationdata

    def getStationsInRange(self, latitude, longitude, range):
        """
        """
        nlat, wlon, slat, elon = dist.boundingBox(latitude, longitude, range)
        res = []
        for station in self.stationsRechargeData.values():
            if(station.consolidated_longitude >= wlon
               and station.consolidated_longitude <= elon
               and station.consolidated_latitude <= nlat
               and station.consolidated_latitude >= slat):
               res.append(station)
        return res



@dataclass
class StationRecharge:
    """
    StationRecharge
    """
    # TODO: add :str to the rest of member variables
    nom_station: str = "N/A"
    coordonneesXY: str = "N/A"
    adresse_station: str = "N/A"
    code_insee_commune: str = "N/A"
    nbre_pdc: str = "N/A"
    consolidated_longitude: str = "N/A"
    consolidated_latitude: str = "N/A"
    consolidated_code_postal: str = "N/A"
    consolidated_commune: str = "N/A"
    consolidated_is_lon_lat_correct: str = "N/A"
    consolidated_is_code_insee_verified: str = "N/A"
    nom_amenageur: str = "N/A"
    siren_amenageur: str = "N/A"
    contact_amenageur: str = "N/A"
    nom_operateur: str = "N/A"
    contact_operateur: str = "N/A"
    telephone_operateur: str = "N/A"
    nom_enseigne: str = "N/A"
    id_station_itinerance: str = "N/A"
    id_station_local: str = "N/A"
    implantation_station: str = "N/A"
    id_pdc_itinerance: str = "N/A"
    id_pdc_local: str = "N/A"
    puissance_nominale: str = "N/A"
    prise_type_ef: str = "N/A"
    prise_type_2: str = "N/A"
    prise_type_combo_ccs: str = "N/A"
    prise_type_chademo: str = "N/A"
    prise_type_autre: str = "N/A"
    gratuit: str = "N/A"
    paiement_acte: str = "N/A"
    paiement_cb: str = "N/A"
    paiement_autre: str = "N/A"
    tarification: str = "N/A"
    condition_acces: str = "N/A"
    reservation: str = "N/A"
    horaires: str = "N/A"
    accessibilite_pmr: str = "N/A"
    restriction_gabarit: str = "N/A"
    station_deux_roues: str = "N/A"
    raccordement: str = "N/A"
    num_pdl: str = "N/A"
    date_mise_en_service: str = "N/A"
    observations: str = "N/A"
    date_maj: str = "N/A"
    cable_t2_attache: str = "N/A"
    last_modified: str = "N/A"
    datagouv_dataset_id: str = "N/A"
    datagouv_resource_id: str = "N/A"
    datagouv_organization_or_owner: str = "N/A"

