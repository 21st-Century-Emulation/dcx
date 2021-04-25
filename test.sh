docker build -q -t dcx .
docker run --rm --name dcx -d -p 8080:8080 dcx

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":11,"state":{"a":10,"b":0,"c":0,"d":5,"e":5,"h":0,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":11,"state":{"a":10,"b":255,"c":255,"d":5,"e":5,"h":0,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":5,"interruptsEnabled":true}}'

docker kill dcx

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mDCX Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mDCX Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi