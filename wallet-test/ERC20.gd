extends Control

export var contract_address = ""

var symbol = ""
var erc20_abi
var contract

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
	get_node("balance").set_text(p[0])

func init_web3(p_web3, abi):
	web3_utils = JavaScript.get_interface("web3_utils")	
	web3 = p_web3
	erc20_abi = abi
	
	contract = web3_utils.new_contract(erc20_abi, contract_address)
	
	update()

func update():
	contract.methods.balanceOf(get_parent().get_account()).call().then(balance_updated)
	contract.methods.symbol().call().then(symbol_updated)


func _ready():
	pass


