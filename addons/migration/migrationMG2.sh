#/bin/bash

CONTENT_DUMP=$1
DATABASE_DUMP=$2

function configuration()
{
    HTTP_HOST=${READVALUE}
    BASE_PATH=${READVALUE}
    DB_HOST=${READVALUE}
    DB_USER=${READVALUE}
    DB_PASSWORD=${READVALUE}
    DB_NAME=${READVALUE}
}

function printString()
{
        echo "$@";
}

function printError()
{
    >&2 echo "$@";
    return 1;
}


function runCommand()
{
    local _prefixMessage=${1:-};
    local _suffixMessage=${2:-}
    echo "${_prefixMessage}${CMD}${_suffixMessage}"
    eval ${CMD};
}



function extract()
{
     if [ -f "$EXTRACT_FILENAME" ] ; then
         case $EXTRACT_FILENAME in
             *.tar.*|*.t*z*)
                CMD="tar $(getStripComponentsValue ${EXTRACT_FILENAME}) -xf ${EXTRACT_FILENAME}"
             ;;
             *.gz)              CMD="gunzip $EXTRACT_FILENAME" ;;
             *.zip)             CMD="unzip -qu -x $EXTRACT_FILENAME" ;;
             *)                 printError "'$EXTRACT_FILENAME' cannot be extracted"; CMD='' ;;
         esac
        runCommand
     else
         printError "'$EXTRACT_FILENAME' is not a valid file"
     fi
}

function getStripComponentsValue()
{
    local stripComponents=
    local slashCount=
    slashCount=$(tar -tf "$1" | grep -v vendor | fgrep pub/index.php | sed 's/pub[/]index[.]php//' | sort | head -1 | tr -cd '/' | wc -m | tr -d ' ')

    if [[ "$slashCount" -gt 0 ]]
    then
        stripComponents="--strip-components=$slashCount"
    fi

    echo "$stripComponents";
}

function mysqlQuery()
{
    CMD="${BIN_MYSQL} -h${DB_HOST} -u${DB_USER} --password=\"${DB_PASSWORD}\" --execute=\"${SQLQUERY}\"";
    runCommand
}

function prepareBasePath()
{
    BASE_PATH=$(echo "${BASE_PATH}" | sed "s/^\///g" | sed "s/\/$//g" );
}

function prepareBaseURL()
{
    prepareBasePath
    HTTP_HOST=$(echo ${HTTP_HOST}/ | sed "s/\/\/$/\//g" );
    BASE_URL=${HTTP_HOST}${BASE_PATH}/
    BASE_URL=$(echo "$BASE_URL" | sed "s/\/\/$/\//g" );
}

function getCodeDumpFilename()
{
    local codeDumpFilename="";
    if [[ -f "$(getRequest codedump)" ]]
    then
        codeDumpFilename="$(getRequest codedump)";
        echo "$codeDumpFilename";
        return 0;
    fi
    codeDumpFilename=$(find . -maxdepth 1 -name '*.tbz2' -o -name '*.tar.bz2' | head -n1)
    if [ "${codeDumpFilename}" == "" ]
    then
        codeDumpFilename=$(find . -maxdepth 1 -name '*.tar.gz' | grep -v 'logs.tar.gz' | head -n1)
    fi
    if [ ! "$codeDumpFilename" ]
    then
        codeDumpFilename=$(find . -maxdepth 1 -name '*.tgz' | head -n1)
    fi
    if [ ! "$codeDumpFilename" ]
    then
        codeDumpFilename=$(find . -maxdepth 1 -name '*.zip' | head -n1)
    fi

    echo "$codeDumpFilename";
    return 0;
}


function getDbDumpFilename()
{
    local dbDumpFilename="";
    if [[ -f "$(getRequest dbdump)" ]]
    then
        dbDumpFilename="$(getRequest dbdump)";
        echo "$dbDumpFilename";
        return 0;
    fi
    dbdumpFilename=$(find . -maxdepth 1 -name '*.sql.gz' | head -n1)
    if [ ! "$dbdumpFilename" ]
    then
        dbdumpFilename=$(find . -maxdepth 1 -name '*_db.gz' | head -n1)
    fi
    if [ ! "$dbdumpFilename" ]
    then
        dbdumpFilename=$(find . -maxdepth 1 -name '*.sql' | head -n1)
    fi
    echo "$dbdumpFilename";
    return 0;
}


function printConfirmation()
{
    printComposerConfirmation
    printGitConfirmation
    prepareBaseURL
    printString "BASE URL: ${BASE_URL}"
    printString "BASE PATH: ${BASE_PATH}"
    printString "DB PARAM: ${DB_USER}@${DB_HOST}"
    printString "DB NAME: ${DB_NAME}"
    printString "DB PASSWORD: ${DB_PASSWORD}"
    printString "MAGE MODE: ${MAGE_MODE}"
    printString "BACKEND FRONTNAME: ${BACKEND_FRONTNAME}"
    printString "ADMIN NAME: ${ADMIN_NAME}"
    printString "ADMIN PASSWORD: ${ADMIN_PASSWORD}"
    printString "ADMIN FIRSTNAME: ${ADMIN_FIRSTNAME}"
    printString "ADMIN LASTNAME: ${ADMIN_LASTNAME}"
    printString "ADMIN EMAIL: ${ADMIN_EMAIL}"
    printString "TIMEZONE: ${TIMEZONE}"
    printString "LANGUAGE: ${LANGUAGE}"
    printString "CURRENCY: ${CURRENCY}"
    if foundSupportBackupFiles
    then
        return;
    fi
    if [ "${USE_SAMPLE_DATA}" ]
    then
        printString "Sample Data will be installed."
    else
        printString "Sample Data will NOT be installed."
    fi
    if [ "${INSTALL_EE}" ]
    then
        printString "Magento EE will be installed"
    else
        printString "Magento EE will NOT be installed."
    fi
}

function dropDB()
{
    SQLQUERY="DROP DATABASE IF EXISTS ${DB_NAME}";
    mysqlQuery
}
function createNewDB()
{
    SQLQUERY="CREATE DATABASE IF NOT EXISTS ${DB_NAME}";
    mysqlQuery
}


function configure_files()
{
    CMD="find -L ./pub -type l -delete"
    runCommand
    updateMagentoEnvFile
    overwriteOriginalFiles
    CMD="find . -type d -exec chmod 775 {} \; && find . -type f -exec chmod 664 {} \;"
    runCommand
}
function configure_db()
{
    updateBaseUrl
    clearBaseLinks
    clearCookieDomain
    clearSslFlag
    clearCustomAdmin
    resetAdminPassword
}
function validateDeploymentFromDumps()
{
    local files=(
      'composer.json'
      'composer.lock'
      'index.php'
      'pub/index.php'
      'pub/static.php'
    );
    local directories=("app" "bin" "dev" "lib" "pub/errors" "setup" "vendor");
    missingDirectories=();
    for dir in "${directories[@]}"
    do
        if [ ! -d "$dir" ]; then
            missingDirectories+=("$dir");
        fi
    done
    if [[ "${missingDirectories[@]-}" ]]
    then
        echo "The following directories are missing: ${missingDirectories[@]}";
    fi
    missingFiles=()
    for file in "${files[@]}"
    do
        if [ ! -f "$file" ]; then
            missingFiles+=("$file");
        fi
    done
    if [[ "${missingFiles[@]-}" ]]
    then
        echo "The following files are missing: ${missingFiles[@]}";
    fi
    if [[ "${missingDirectories[@]-}" || "${missingFiles[@]-}" ]]
    then
        printError "Download missing files and directories from vanilla magento"
    fi
}

function updateBaseUrl()
{
    SQLQUERY="UPDATE ${DB_NAME}.$(getTablePrefix)core_config_data AS e SET e.value = '${BASE_URL}' WHERE e.path IN ('web/secure/base_url', 'web/unsecure/base_url')"
    mysqlQuery
}
function clearBaseLinks()
{
    SQLQUERY="DELETE FROM ${DB_NAME}.$(getTablePrefix)core_config_data WHERE path IN ('web/unsecure/base_link_url', 'web/secure/base_link_url', 'web/unsecure/base_static_url', 'web/unsecure/base_media_url', 'web/secure/base_static_url', 'web/secure/base_media_url')";
    mysqlQuery
}
function clearCookieDomain()
{
    SQLQUERY="DELETE FROM ${DB_NAME}.$(getTablePrefix)core_config_data WHERE path = 'web/cookie/cookie_domain'"
    mysqlQuery
}
function clearSslFlag()
{
    SQLQUERY="UPDATE ${DB_NAME}.$(getTablePrefix)core_config_data AS e SET e.value = 0 WHERE e.path IN ('web/secure/use_in_adminhtm', 'web/secure/use_in_frontend')"
    mysqlQuery
}
function clearCustomAdmin()
{
    SQLQUERY="DELETE FROM ${DB_NAME}.$(getTablePrefix)core_config_data WHERE path = 'admin/url/custom'"
    mysqlQuery
    SQLQUERY="UPDATE ${DB_NAME}.$(getTablePrefix)core_config_data SET ${DB_NAME}.$(getTablePrefix)core_config_data.value = '0' WHERE path = 'admin/url/use_custom'"
    mysqlQuery
    SQLQUERY="DELETE FROM ${DB_NAME}.$(getTablePrefix)core_config_data WHERE path = 'admin/url/custom_path'"
    mysqlQuery
    SQLQUERY="UPDATE ${DB_NAME}.$(getTablePrefix)core_config_data SET ${DB_NAME}.$(getTablePrefix)core_config_data.value = '0' WHERE path = 'admin/url/use_custom_path'"
    mysqlQuery
}
function resetAdminPassword()
{
    SQLQUERY="UPDATE ${DB_NAME}.$(getTablePrefix)admin_user SET ${DB_NAME}.$(getTablePrefix)admin_user.email = '${ADMIN_EMAIL}' WHERE ${DB_NAME}.$(getTablePrefix)admin_user.username = '${ADMIN_NAME}'"
    mysqlQuery
    CMD="${BIN_MAGE} admin:user:create
        --admin-user='${ADMIN_NAME}'
        --admin-password='${ADMIN_PASSWORD}'
        --admin-email='${ADMIN_EMAIL}'
        --admin-firstname='${ADMIN_FIRSTNAME}'
        --admin-lastname='${ADMIN_LASTNAME}'"
    runCommand
}


function getTablePrefix()
{
    echo $(grep 'table_prefix' app/etc/env.php | head -n1 | sed "s/[a-z'_ ]*[=][>][ ]*[']//" | sed "s/['][,]//")
    return 0;
}

export LC_CTYPE=C
export LANG=C
function main()
{

	extract;

	echo asdasdasdsd


}
main "${@}"
