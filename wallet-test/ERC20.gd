extends Control

export var contract_address = ""

var symbol = ""
var balance = 0
var erc20_abi
var contract
var wallet

onready var balance_updated = JavaScript.create_callback(self, "_balance_updated")
onready var symbol_updated = JavaScript.create_callback(self, "_symbol_updated")

var web3
var web3_utils

func _symbol_updated(p):

	web3_utils.debug(p[0])
	symbol = p[0]
	get_node("name").set_text(symbol)

func _balance_updated(p):
	
	web3_utils.debug(p[0])
	balance = p[0]
	get_node("balance").set_text(p[0])

func init_web3(p_web3, abi):
	web3_utils = JavaScript.get_interface("web3_utils")	
	web3 = p_web3
	erc20_abi = abi

	wallet = get_node("/root/wallet")
	
	contract = web3_utils.new_contract(erc20_abi, contract_address)
	contract.options.from = wallet.get_account()

	update()

func update():
	contract.methods.balanceOf(wallet.get_account()).call().then(balance_updated)
	contract.methods.symbol().call().then(symbol_updated)


func _ready():
	pass


