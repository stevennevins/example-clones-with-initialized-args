all    : users test;
users   :; node blacksmith.js create
build :; node blacksmith.js build
test :; forge test -vvv 
report :; forge test --gas-report -vvv
deps :; git submodule update --init --recursive
install :; npm install
prettier :; npm run prettier
