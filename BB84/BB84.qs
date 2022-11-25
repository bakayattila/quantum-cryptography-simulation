namespace Quantum.BB84 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    
    @EntryPoint()
    operation Start () : Unit {
      generateKey(10, false);
      
   }
    operation generateKey(max : Int, isEve : Bool) : Unit {
            mutable AliceKey = "";
            mutable BobKey = "";

            mutable AliceBase ="";

            mutable Key = "";
            mutable ActualKey = "";

            mutable i = 0;
            mutable Cycle = 0;

            repeat{
                let a = randomBit();
                let b = randomBit();

                set AliceKey += toString(a);
                set AliceBase += toString(b);
                use q = Qubit();
                Alice(q,a,b);

                if isEve {Eve(q);}                

                let keybit = Bob(q,b);
                set BobKey += keybit;
                
                if keybit != "*" {
                  set Key += keybit;
                  set ActualKey += toString(a);
                 set i+= 1;
                }

                print(Cycle, AliceKey, AliceBase, BobKey, Key, ActualKey, isEve);
                set Cycle += 1;
            } until(i == max);                    
       
        print(Cycle, AliceKey, AliceBase, BobKey, Key, ActualKey, isEve);
    }

    //Eve just listens in the |0> |1> base
    operation Eve(q : Qubit) : Unit{
       let listen = M(q);
    }

   operation Alice (q: Qubit, a : Result, b : Result) : Unit {      
      // Creating random state and base
      if a == One{
          X(q);
      }        
      if b == One{
          H(q);
      }     
    }


   operation Bob(q : Qubit, b : Result) : String {

      //Bob creates random b'
      let bcomma = randomBit();

      if bcomma == One{
          H(q);
      }

      //Bob measures in |0> or |+> base based b' 
      let result = M(q);

       //Bob compares b with b' if they are equal, the result is part of the key
      if b == bcomma {
           return toString(result);
      } 
      else {
          return "*";
      }       
   }

   operation toString(result : Result) : String {
       if result == Zero {
         return "0";
       }else{
         return "1";
       }
   }

   operation randomBit() : Result {
        use q = Qubit();
        H(q);
        return M(q);
   }
   //Displaying the state of the protocol in each cycle
   operation print(cycle :Int ,AliceKey : String, AliceBase : String, BobKey : String, key : String, actualKey : String , eve : Bool) : Unit{
        
       Message($"state of the BB84 at {cycle} bit. Eve is listening: {eve}");
       Message("Alice generated:");
       Message(AliceKey);
       Message("Alice flipped base:");
       Message(AliceBase);
       Message("Bob received:");
       Message(BobKey); 
       Message("The key is: ");
       Message(key);
       Message("The actual key is:");
       Message(actualKey);
       Message("----");
    }
}

