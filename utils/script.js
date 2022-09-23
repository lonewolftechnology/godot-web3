<script src="https://cdn.jsdelivr.net/gh/ethereum/web3.js/dist/web3.min.js"></script>



var web3_instance;

var sign;

var web3_utils = {

    init_web3: function() {

      web3_instance = new Web3(window.ethereum);
      return web3_instance;
   },

   new_contract: function(abi, addr) {

       return new web3_instance.eth.Contract(abi, addr);
   },

  debug: function(obj) {

    console.log(JSON.stringify(obj));
  },
};

var metamask = {
    sign_v4: function(signer) {

        const msgParams = SON.stringify({
            domain: {
              // Defining the chain aka Rinkeby testnet or Ethereum Main Net
              chainId: 1,
              // Give a user friendly name to the specific contract you are signing for.
              name: 'Signature test',
              // If name isn't enough add verifying contract to make sure you are establishing contracts with the proper entity
              verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
              // Just let's you know the latest version. Definitely make sure the field name is correct.
              version: '1',
            },
        
            // Defining the message signing data content.
            message: {
              /*
               - Anything you want. Just a JSON Blob that encodes the data you want to send
               - No required fields
               - This is DApp Specific
               - Be as explicit as possible when building out the message schema.
              */
             title: "this is a boy"
            },
            // Refers to the keys of the *types* object below.
            primaryType: 'Mail',
            types: {
              // TODO: Clarify if EIP712Domain refers to the domain the contract is hosted on
              EIP712Domain: [
                { name: 'name', type: 'string' },
                { name: 'version', type: 'string' },
                { name: 'chainId', type: 'uint256' },
                { name: 'verifyingContract', type: 'address' },
              ],
              // Refer to PrimaryType
              Mail: [
                { name: 'title', type: 'string' },
              ],
            },
          });;
    
        var params = [signer, msgParams];
        var method = 'eth_signTypedData_v4';
    
        web3.currentProvider.sendAsync(
            {
                method,
                params,
                signer,
            },
            function (err, result) {
                  console.log(result);
                  sign = result.result;
            }
        )
      },

      get_result: function() {
        
        console.log(sign);
      }
};