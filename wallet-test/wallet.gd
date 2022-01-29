extends Control

var web3
var web3_utils
var erc20_abi
var anim
var jsjson
var accounts = []
var tokens = []

var accts_ready = JavaScript.create_callback(self, "_accts_ready")
var main_balance_ready = JavaScript.create_callback(self, "_main_balance_ready")

var token_send_return = JavaScript.create_callback(self, "_token_send_return")
var token_send_error = JavaScript.create_callback(self, "_token_send_error")
var token_send_tx_hash = JavaScript.create_callback(self, "_token_send_tx_hash")

var sign_returned = JavaScript.create_callback(self, "_sign_returned")
var sign_error = JavaScript.create_callback(self, "_sign_error")
var sign_recover_returned = JavaScript.create_callback(self, "_sign_recover_returned")
var sign_recover_error = JavaScript.create_callback(self, "_sign_recover_error")


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

	for t in tokens:
		t.init_web3(web3, erc20_abi)
	
	update()

func status_update(msg):
	
	get_node("status").set_text(msg)

func update():
	web3.eth.getBalance(accounts[0]).then(main_balance_ready)
	
func connect_pressed():

	web3_utils = JavaScript.get_interface("web3_utils")

	var win = JavaScript.get_interface("window")
	if win.ethereum:
		var promise = win.ethereum.send("eth_requestAccounts").then(accts_ready)
		anim.play("connecting")
		printt("connecting ...", promise)

	return

func tab_changed(tab):
	
	if tab == 0:
		for t in tokens:
			t.update()
		
	if tab == 1:
		var options = get_node("tabs/Send/tokens")
		options.clear()
		for t in tokens:
			options.add_item(t.symbol)
		options.select(0)

####### token sending

func send_max_pressed():
	var t = get_node("tabs/Send/tokens").get_selected()
	get_node("tabs/Send/amount").set_text(tokens[t].balance)

func send_pressed():
	var t = get_node("tabs/Send/tokens").get_selected()
	token_transfer(tokens[t], get_node("tabs/Send/recipient").get_text(), get_node("tabs/Send/amount").get_text())

func token_transfer(token, recipient, amount):
	token.contract.methods.transfer(recipient, amount).send({"from": get_account()}).\
		once('transactionHash', token_send_tx_hash).\
		on("error", token_send_error).\
		then(token_send_return)
	status_update("Signing transaction ...")

func _token_send_return(p):
	printt("token send return!", p)
	web3_utils.debug(p[0])
	status_update("Confirmed! tx hash " + p[0].transactionHash)

func _token_send_error(p):
	status_update(p[0].message)

func _token_send_tx_hash(p):
	status_update("Tx " + p[0] + " sent, waiting for confirmation ...")


######## signing

func sign_pressed():
	var msg = get_node("tabs/Sign/msg").get_text()
	web3.eth.personal.sign(msg, get_account()).then(sign_returned).catch(sign_error)
	status_update("Requesting signature ...")

func _sign_returned(p):
	status_update("Signed!")
	
	var msg = get_node("tabs/Sign/msg").get_text()
	
	var acct = web3.eth.personal.ecRecover(msg, p[0]).then(sign_recover_returned).catch(sign_recover_error)
	
func _sign_error(p):
	status_update(p[0].message)
	
func _sign_recover_returned(p):
	get_node("tabs/Sign/recover").set_text(p[0])
	
func _sign_recover_error(p):
	printt("sign recover error! ", p)
	web3_utils.debug(p[0])

	
func _ready():
	anim = get_node("animation")
	get_node("connect").connect("pressed", self, "connect_pressed")

	jsjson = JavaScript.get_interface("JSON")

	var file = File.new()
	file.open("res://erc20.json", File.READ)
	var content = file.get_as_text()
	file.close()
	erc20_abi = jsjson.parse(content)

	var vbox = get_node("tabs/Assets")
	for i in vbox.get_child_count():
		var c = vbox.get_child(i)
		if c is preload("res://ERC20.gd"):
			tokens.push_back(c)

	get_node("tabs").connect("tab_changed", self, "tab_changed")
	get_node("tabs/Send/max").connect("pressed", self, "send_max_pressed")
	get_node("tabs/Send/send").connect("pressed", self, "send_pressed")

	get_node("tabs/Sign/sign").connect("pressed", self, "sign_pressed")



func _on_sign_pressed():
	web3_utils = JavaScript.get_interface('web3_utils')
	
	var result = web3_utils.metamask_sign_v4(accounts[0])
	
	return
