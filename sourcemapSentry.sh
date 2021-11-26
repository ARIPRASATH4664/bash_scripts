read -p "Generate Android Source Map: y/n " android
read -p "Is Hermes Enabled: y/n " hermes
if [ $hermes == "y" ]
    then
    read -p "OS (osx-bin, win64-bin, linux64-bin) : " os
fi
read -p "Generate Ios Source Map: y/n " ios
read -p "App version : " version
if [ $android == "y" ]
    then
    read -p "Build Number Android : " androidDist
fi
if [ $ios == "y" ]
    then
    read -p "Build Number Ios : " iosDist
fi

border () {
    local string="$*"
    local length=${#string}
    local i
    for (( i = 0; i < length + 4; ++i )); do
        printf "\033[1;35m-"
    done
    printf "\n| \033[1;96m$string\033[1;35m | \n"
    for (( i = 0; i < length + 4; ++i )); do
        printf "-"
    done
    printf "\n\033[0m"
}

# Moving into the folder
cd Desktop/RenterApp

# Android SourceMap Generation 
if [ $android == "y" ]
    then 
    react-native bundle --dev false --platform android --entry-file App.js --bundle-output index.android.bundle --sourcemap-output index.android.bundle.packager.map
    androidSts=$?
    hermesSts=0
    composeSts=0
    androidUploadSts=1
    if [ $androidSts == 0 ] && [ $hermes == "y" ]
        then
        ./node_modules/hermes-engine/$os/hermesc -O -emit-binary -output-source-map -out=index.android.bundle.hbc index.android.bundle
        hermesSts=$?
    fi 
    if [ $hermesSts == 0 ] && [ $hermes == "y" ]
        then
        node node_modules/react-native/scripts/compose-source-maps.js index.android.bundle.packager.map index.android.bundle.hbc.map -o index.android.bundle.map
        composeSts=$?
    fi
    # Uploading Source map
    if [ $hermes == "y" ] && [ $hermesSts == 0 ] && [ $composeSts == 0 ]
        then
        ./node_modules/@sentry/cli/bin/sentry-cli releases --org rently-si --project renterapp files com.renterapp@$version+$androidDist upload-sourcemaps --dist $androidDist --strip-prefix /Users/rentlycoimbatore/Desktop/RenterApp --rewrite ./index.android.bundle ./index.android.bundle.map
        androidUploadSts=$?
    elif [ $androidSts == 0]
        then
        ./node_modules/@sentry/cli/bin/sentry-cli releases --org rently-si --project renterapp files com.renterapp@$version+$androidDist upload-sourcemaps --dist $androidDist --strip-prefix /Users/rentlycoimbatore/Desktop/RenterApp --rewrite ./index.android.bundle ./index.android.bundle.packager.map
        androidUploadSts=$?
    fi
    if [ $androidUploadSts == 0 ]
        then
        border "Android Status Success."
    else
        border "Android Status Failure."
    fi
fi
# Ios SourceMap Generation
if [ ios == "y" ]
    then
    react-native bundle   --dev false   --platform ios   --entry-file index.js   --bundle-output main.jsbundle   --sourcemap-output main.jsbundle.map
    iosSts=$?
    iosUploadSts=1
    if [ $iosSts == 0 ]
        then
        ./node_modules/@sentry/cli/bin/sentry-cli releases --org rently-si --project renterapp files com.rently.renterapp@$version+$iosDist upload-sourcemaps --dist $iosDist --strip-prefix . --rewrite main.jsbundle main.jsbundle.map
        iosUploadSts=$?
    fi
    if [ $iosUploadSts == 0 ]
        then
        border "Ios Status Success."
    else
        border "Ios Status Failure."
    fi
fi

