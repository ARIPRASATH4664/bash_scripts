#To echo box output

function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

read -p "Enter android or ios: " os
read -p "Perform init y/n ? " init
cd Desktop/RenterApp
if [ $init == "y" ]
then
npm i
sts=$?
if [ $sts != 0 ]
then
box_out "npm install default failed"
npm i --legacy-peer-deps
sts=$?
fi
if [ $sts == 0 ]
box_out "npm install success"
then
cd ios && pod deintegrate && pod install && cd ..
podSts=$?
if [ podSts != 0 ]
then
cd ios & pod update && cd ..
fi
box_out "POD INSTALL DONE"
fi
fi
if [ $os == "ios" ]
then
# --terminal --tab --command="bash -c 'npm start $SHELL'"
# osascript -e "tell application \"Terminal\" to do script \"cd Desktop/RenterApp && npm start\" in selected tab of the front window";
osascript -e 'tell application "Terminal" to activate' -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down' -e 'tell application "Terminal" to do script "cd Desktop/RenterApp && npm start" in selected tab of the front window'
react-native run-ios --simulator='iPhone 12 mini'
elif [ $os == "android" ]
then
osascript -e 'tell application "Terminal" to activate' -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down' -e 'tell application "Terminal" to do script "cd Desktop/RenterApp && npm start" in selected tab of the front window'
react-native run-android
else
box_out "INIT DONE"
fi

box_out "**********************END********************"
