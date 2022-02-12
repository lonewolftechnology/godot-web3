# godot-web3

This is an example of how to use web3 on godot for HTML5 exports with Godot 3.5. This code uses Godot's [Javascript Interface](https://godotengine.org/article/godot-web-progress-report-9) for most calls, with some added javascript utility code added.

The usage pattern in GDScript is the same as in Javascript, so checking the standard [web3 documentation](https://web3js.readthedocs.io/en/v1.7.0/) is recommended.

## Setup your export

Before you start, you need to make some Javascript code available on the HTML export. On the Export Settings window, go into your HTML5 export preset, and add the contents of [utils/web3_utils.html](utils/web3_utils.html) on the `Head Include` section. This will load the web3.js source from a CDN, and create the "web3_utils" javascript object.

## Connecting to metamask

To connect to metamask, check for `window.ethereum`, then send the `eth_requestAccounts` message. This will popup the Metamask connection request. Remember everything is asynchronous, you'll need to make a callback to catch the response as indicated in the [Javascript Interface](https://godotengine.org/article/godot-web-progress-report-9) article.


```gdscript
var accts_ready = JavaScript.create_callback(self, "_accts_ready")

func connect_pressed():

	web3_utils = JavaScript.get_interface("web3_utils")

	var win = JavaScript.get_interface("window")
	if win.ethereum:
		win.ethereum.send("eth_requestAccounts").then(accts_ready)
		anim.play("connecting")

	return
```

When the accounts come back, the list of accounts will be in the `p[0].result` array (`p` is the parameter to the callback).

Use the method `web3_utils.init_web3` to instance a Web3 object, this will set `window.ethereum` as the provider.


```gdscript
func _accts_ready(p):
	anim.play("connected")
	accounts.clear()
	for i in p[0].result.length:
		accounts.push_back(p[0].result[i])
		
	get_node("account").set_text("")
	if accounts.size():
		get_node("account").set_text(accounts[0])

	web3 = web3_utils.init_web3()

	update()
```

Now you're ready to use web3. Use getBalance to request the main balance of the account

```gdscript
var main_balance_ready = JavaScript.create_callback(self, "_main_balance_ready")

func update():
	web3.eth.getBalance(accounts[0]).then(main_balance_ready)
```

When the balance comes back, the result will be in `p[0]`

```gdscript
func _main_balance_ready(p):
	
	get_node("balance").set_text(p[0])

```

See [wallet-test/wallet.gd](wallet-test/wallet.gd) for more detail.

## Calling smart contracts

First, you'll need to instance the contract. Use the `web3_utils.new_contract` method to get a contract instance. You need to provide the contract ABI.

Popular ABIs are incuded in `wallet-test`.

Use javascript's own json parser to obtain the json object, then pass it as parameter to `web3_utils.new_contract`, along with the contract address


```gdscript
func _ready():
	jsjson = JavaScript.get_interface("JSON")

	var file = File.new()
	file.open("res://erc20.json", File.READ)
	var content = file.get_as_text()
	file.close()
	erc20_abi = jsjson.parse(content)
```

Later, after the web3 object is created

```gdscript
func init_web3(p_web3, abi):
	web3_utils = JavaScript.get_interface("web3_utils")	
	web3 = p_web3
	erc20_abi = abi

	wallet = get_node("/root/wallet")
	
	contract = web3_utils.new_contract(erc20_abi, contract_address)
	contract.options.from = wallet.get_account()

	update()
```

Set the `contract.options.from` parameter to the source address, for calls that need to be signed.

## Read-only calls

To call a read-only method from the contract, use the `call` method

```gdscript
func update():
	contract.methods.balanceOf(wallet.get_account()).call().then(balance_updated)
	contract.methods.symbol().call().then(symbol_updated)
```

Calls are still asynchronous, so create callbacks as usual.

The return value of the call will be in `p[0]`

```gdscript
func _symbol_updated(p):

	symbol = p[0]
	get_node("name").set_text(symbol)

func _balance_updated(p):
	
	balance = p[0]
	get_node("balance").set_text(p[0])
```

See [wallet-test/ERC20.gd](wallet-test/ERC20.gd) for more detail.

## Signed calls

For calls that modify the blockchain, use `send` on the contract method.

```gdscript
func token_transfer(token, recipient, amount):
	token.contract.methods.transfer(recipient, amount).send({"from": get_account()}).\
		once('transactionHash', token_send_tx_hash).\
		on("error", token_send_error).\
		then(token_send_return)
	status_update("Signing transaction ...")
```

This calls the `transfer` method on the ERC20 contact. Note that we use multiple callbacks to catch different events and error conditions, consult the [web3.js documentation](https://web3js.readthedocs.io/en/v1.7.0/) for details.

In this case, we catch errors (can be caused by the user refusing to sign the transaction, or an error from Metamask), or a successful call. We also get a callback when the transaction hash is available.

```gdscript
func _token_send_return(p):
	status_update("Confirmed! tx hash " + p[0].transactionHash)

func _token_send_error(p):
	status_update(p[0].message)

func _token_send_tx_hash(p):
	status_update("Tx " + p[0] + " sent, waiting for confirmation ...")
```

### Signing messages

To request a signed message from the wallet, use the `web3.eth.personal.sign` method.

```gdscript
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
```

This will cause Metamask to show the sign message popup. The signed message is in `p[0]`. In this example we use `web3.eth.personal.ecRecover` right away to verify the signature, by passing the original message and the signed message, the expected result is the signing account. This is still an asynchronous call

```gdscript
func _sign_recover_returned(p):
	var signature_valid = p[0] == get_account()
	if signature_valid:
		status_update("Valid!")
	else:
		status_update("Invalid!")
	
func _sign_recover_error(p):
	status_update(p[0].message)
```

