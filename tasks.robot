*** Settings ***
Documentation     Robot de commande
...               Commande des robotrs depuis le site Robot Spare Bin
...               Enregistre les commandes html dans un fichier pdf unique
...               Enregistre une capture d'écran dans le pdf unique
...               Créé un fichier .zip des reçu et de l'image
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF
Library           RPA.Robocorp.Vault
# Au cas où on voudrait charger les credentials en local
#Library          RPA.Robocloud.Secrets

*** Variables ***
${coffre} =       Get Secret    credentials
${login} =        ${coffre}[login]
${mdp} =          ${coffre}[password]

*** Keywords ***

*** Tasks ***
Entre sur le site robot
    Log    Done.

Renseigne les infos achat
    No Operation

Telecharge le reçu avec une capture ecran
    No Operation
