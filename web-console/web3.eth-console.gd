extends Control

# TODO - Make JS variables resuable and changeable
# TODO - Make JS output visble to gdscript
# TODO - Deal with callback i.e display result of callback in gdscript

func _getMetamaskAccount():
	 if OS.has_feature('JavaScript'):
			JavaScript.eval("""
			const Provider = 'http://localhost:8545';
			var web3 = new Web3(Provider);
			const ethEnabled = async () => {
			  if (window.ethereum) {
				await window.ethereum.send('eth_requestAccounts');
				window.web3 = new Web3(window.ethereum);
				return true;
			  }
			  return false;
			}
		ethEnabled()
		""")
		else:
			print("The JavaScript singleton is NOT available")
			
func _getGasPrice():
	 if OS.has_feature('JavaScript'):
			JavaScript.eval("""
			var web3 = new Web3('http://localhost:8545');
			web3.eth.getGasPrice()
			.then(console.log);
		""")
		else:
			print("The JavaScript singleton is NOT available")
			
func _getAllAccounts():
	 if OS.has_feature('JavaScript'):
			JavaScript.eval("""
			var web3 = new Web3('http://localhost:8545');
			web3.eth.getAccounts()
			.then(console.log);
		""")
		else:
			print("The JavaScript singleton is NOT available")

func _getblockNumber():
	 if OS.has_feature('JavaScript'):
			JavaScript.eval("""
			var web3 = new Web3('http://localhost:8545');
			web3.eth.getBlockNumber()
			.then(console.log);
		""")
		else:
			print("The JavaScript singleton is NOT available")
			
# TODO - Users should be able to input address from Godot to Javascript
func _getEthBalance():
	 if OS.has_feature('JavaScript'):
			JavaScript.eval("""
			var web3 = new Web3('http://localhost:8545');
			var address = "0xA768a7f2903631A097185B2a4C37Eb1b410A03b4"
			web3.eth.getBalance(address)
			.then(console.log);
		""")
		else:
			print("The JavaScript singleton is NOT available")

func _getBlockDetails():
	 if OS.has_feature('JavaScript'):
			JavaScript.eval("""
			var web3 = new Web3('http://localhost:8545');
			var blockNumber = '';
			web3.eth.getBlock(blockNumber)
			.then(console.log);
		""")
		else:
			print("The JavaScript singleton is NOT available")

# code is compiled solidity contract
# create transaction Object as gdscript object and make it readable by JS
func _sendTransaction():
	if OS.has_feature('Javascript'):
		JavaScript.eval("""
		var code = '';
		
		""")