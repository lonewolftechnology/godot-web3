extends Control

var web3
var web3_utils
var erc20_abi
var anim
var jsjson
var accounts = []

var accts_ready = JavaScript.create_callback(self, "_accts_ready")
var main_balance_ready = JavaScript.create_callback(self, "_main_balance_ready")

func get_account():
	if accounts.size():
		return accounts[0]
		
	return null

func _main_balance_ready(p):
	
	web3_utils.debug(p[0])
	get_node("balance").set_text(p[0])

func _accts_ready(p):
	printt("got accounts ", jsjson.stringify(p[0]))
	
	anim.play("connected")
	accounts.clear()
	for i in p[0].result.length:
		printt("account ", i, p[0].result[i])
		accounts.push_back(p[0].result[i])
		
	get_node("account").set_text("")
	if accounts.size():
		get_node("account").set_text(accounts[0])

	web3 = web3_utils.init_web3()
	get_node("usdt").init_web3(web3, erc20_abi)
	
	web3.eth.getBalance(accounts[0]).then(main_balance_ready)
	
func connect_pressed():

	web3_utils = JavaScript.get_interface("web3_utils")

	var win = JavaScript.get_interface("window")
	if win.ethereum:
		var promise = win.ethereum.send("eth_requestAccounts").then(accts_ready)
		anim.play("connecting")
		printt("connecting ...", promise)
		
		
	return

	
func _ready():
	anim = get_node("animation")
	get_node("connect").connect("pressed", self, "connect_pressed")

	jsjson = JavaScript.get_interface("JSON")

	var file = File.new()
	file.open("res://erc20.json", File.READ)
	var content = file.get_as_text()
	file.close()
	erc20_abi = jsjson.parse(content)


