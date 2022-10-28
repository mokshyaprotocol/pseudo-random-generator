module pseudorandom::random{
    use std::vector;
    use std::bcs;
    use aptos_std::from_bcs;
    use std::hash;
    use aptos_framework::timestamp;
    use aptos_framework::transaction_context;

    const ENO_OVERFLOW:u64 = 0;
    
    public entry fun pseudo_random(add:address,number1:u64,max:u64):u64
    {
        let x = bcs::to_bytes<address>(&add);
        let y = bcs::to_bytes<u64>(&number1);
        let z = bcs::to_bytes<u64>(&timestamp::now_seconds());
        vector::append(&mut x,y);
        vector::append(&mut x,z);
        let script_hash: vector<u8> = transaction_context::get_script_hash();
        vector::append(&mut x,script_hash);
        let tmp = hash::sha2_256(x);

        let data = vector<u8>[];
        let i =24;
        while (i < 32)
        {
            let x =vector::borrow(&tmp,i);
            vector::append(&mut data,vector<u8>[*x]);
            i= i+1;
        };
        assert!(max>0,999);

        let random = from_bcs::to_u64(data) % max;
        random

    }
 
    #[test_only] 
    use aptos_std::debug::print;
    use std::signer;
     #[test(creator = @0xc1ce, pseudorandom = @pseudorandom,framework = @0x1)]
   fun test_randomness(
        creator: signer,
        pseudorandom: signer,
        framework: signer,
    ){
       let sender_addr = signer::address_of(&creator);
        let _addr = signer::address_of(&pseudorandom);
        // set up global time for testing purpose
        timestamp::set_time_has_started_for_testing(&framework);
        let i =1;
        while (i < 10)
        {
        let x = pseudo_random(sender_addr,i,i+2*i);
        print<u64>(&x);
        i=i+1;
        };
    }   
}