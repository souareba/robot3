*** Settings ***
Documentation     Robot de commande
...               Commande des robotrs depuis le site Robot Spare Bin
...               Enregistre les commandes html dans un fichier pdf unique
...               Enregistre une capture d'écran dans le pdf unique
...               Créé un fichier .zip des reçu et de l'image
Library           RPA.Browser.Selenium    auto_close=${False}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
# Library qui sauvegarde les informations confidentiels dans un coffre
Library           RPA.Robocorp.Vault
Library           RPA.Archive
Library           RPA.Dialogs
# Au cas où on voudrait charger les credentials en local
#Library          RPA.Robocloud.Secrets
Task Teardown     Close All Browsers

*** Variables ***
${pathScreen}=    ${OUTPUT_DIR}${/}ScreenRobot${/}robot
${pdfPath}=       ${OUTPUT_DIR}${/}PDF${/}robot
${final_path} =    ${OUTPUT_DIR}${/}DossierFinal

*** Keywords ***
Get orders
    ${orders} =    Read table from CSV    orders.csv    header=true    delimiters=","
    FOR    ${element}    IN    @{orders}
        Select From List By Value    id:head    ${element}[Head]
        Click Button    id-body-${element}[Body]
        Input Text    css:.form-control    ${element}[Legs]
        Input Text    id:address    ${element}[Address]
        Click Button    preview
        Wait Until Element Is Visible    id:robot-preview-image
        Screenshot    id:robot-preview-image    ${pathScreen}-order-${element}[Order number].png
        Click Button    id:order
        ${error} =    Is Element Visible    css:.alert-danger
        ${idorder} =    Is Element Visible    id:order
        IF    ${error} == ${True}
            #Click Button    id:order
            #Click Button    css:.btn-primary
            Wait Until Keyword Succeeds    6x    1s    Click sur Btton
        ELSE
            Log    should pass
        END
        ${recept}=    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${recept}    ${pdfPath}-order-${element}[Order number].pdf
        Open Pdf    ${pdfPath}-order-${element}[Order number].pdf
        Add Watermark Image To Pdf    ${pathScreen}-order-${element}[Order number].png    ${OUTPUT_DIR}${/}DossierFinal/robot-order-${element}[Order number].pdf    ${pdfPath}-order-${element}[Order number].pdf
        #Close Pdf    ${pdfPath}-order-${element}[Order number].pdf
        Wait Until Element Is Visible    id:order-another
        Click Button    id:order-another
        Click Element If Visible    css:.btn-dark
    END
    Creer un zip

Click sur Btton
    Click Element If Visible    css:.btn-primary
    ${receptExist}=    Get Element Attribute    id:receipt    outerHTML

Creer un zip
    ${zip_file_name} =    Set Variable    ${OUTPUT_DIR}${/}DossierFinal.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}DossierFinal    ${zip_file_name}

Entrer la commande Input
    Add heading    Entrer l'url du fichier csv
    Add text input    url    label=url
    ${result}=    Run dialog
    Download    ${result.url}

*** Tasks ***
Download csv file
    Entrer la commande Input
    #Download    https://robotsparebinindustries.com/orders.csv    overwrite=true

Open the robot order website and insert
    ${coffre} =    Get Secret    credentials
    #Log    ${coffre}[login]
    #Log    ${coffre}[password]
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order
    Maximize Browser Window
    #Ferme la fenêtre automatic qui s'affiche au début
    Click Element If Visible    css:.btn-dark
    #Appel le keyword get orders qui ressort les data
    Get orders
