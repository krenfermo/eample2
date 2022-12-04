*** Settings ***
Documentation       Example certificate level 2.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.FileSystem
Library             RPA.Archive
Library             Dialogs

*** Variables ***
${CSV_URL}=    https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    Close the annoying modal
    Create Directory    ${CURDIR}${/}files
    FOR    ${row}    IN    @{orders}
        #Log    ${row}
        
        Fill the form    ${row}

        ${pdf}=    Store the receipt as a PDF file    ${row}
        
        
    END
    Zip the reciepts folder


*** Keywords ***
Open the robot order website
     
    ${csv_archivo}=    Get Value From User
    ...    input url to csv
    ...    https://robotsparebinindustries.com/orders.csv
    Download    ${CSV_URL}    orders.csv

    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Maximize Browser Window

Get orders
    ${dato}=    Read table from CSV    ${CURDIR}${/}orders.csv    header='True'
    RETURN    ${dato}

Close the annoying modal
    Wait Until Page Contains Element    //button[@class="btn btn-dark"]
    Click Button    //button[@class="btn btn-dark"]

Fill the form
    [Arguments]    ${row}
    Select From List By Value    //select[@name="head"]    ${row}[Head]
    Click Element    //input[@value=${row}[Body]]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    //input[@id="address"]    ${row}[Address]
    Click Button    //button[@id="preview"]
    Wait Until Page Contains Element    //div[@id="robot-preview-image"]
    Screenshot    //div[@id="robot-preview-image"]    ${CURDIR}${/}${/}files${row}[Order number].png
    Sleep    5 seconds
    Click Button    //button[@id="order"]
    Sleep    8 seconds
    
Store the receipt as a PDF file
    [Arguments]    ${row}
    ${reciept_data}=    Get Element Attribute    //div[@id="receipt"]    outerHTML
    Html To Pdf    ${reciept_data}    ${CURDIR}${/}files${/}${row}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${CURDIR}${/}files${/}${row}[Order number].png
    ...    ${CURDIR}${/}files${/}${row}[Order number].pdf
    ...    ${CURDIR}${/}files${/}${row}[Order number].pdf
    Click Button    //button[@id="order-another"]
    Close the annoying modal


Zip the reciepts folder
    Archive Folder With Zip    ${CURDIR}${/}files    ${OUTPUT_DIR}${/}files.zip
