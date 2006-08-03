From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 03 Aug 2006 09:09:15 +0000
Subject: Re: RSE and incomplete register frame
Message-Id: <44D1BD3B.2040000@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <44D05F9F.3070804@hob.de>
In-Reply-To: <44D05F9F.3070804@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Chapman schrieb:

>Hi Christian,
>
>It took me a while to get my head around this.  
>
>>while developing an instruction set simulator
>>    
>>
>I'd be interested in learning more about this simulator :)
>
It will become a functional IA64 simulator with some more features 
compared to HP Ski. And in opposite to HP Ski it also has the clean 
partition architected.

>>incomplete register frame (ASDM vol. 2) to be inaccurate. It says that 
>>the incomplete frame becomes complete when RSE.ndirty_words becomes 
>>non-negative by executing mandatory RSE loads. However, mandatory RSE 
>>loads are not touching BSPSTORE or the dirty partition.
>>    
>>
>Indirectly they are, because presumably the dirty partition (and BSPSTORE)
>must remain squeezed between the invalid partition and the current
>partition (albeit being zero-size, or negative-size depending on how you
>look at it - the invalid partition extends into the current partition!).
>
>>RSE loads are extending the clean partition.
>>    
>>
>IMHO there is no clean partition.  The RSE loads are targeting the current
>frame so they are immediately dirty+current.
>
>>Furthermore if you consider RSE.BOF to 
>>end up inside the clean partition after a br.ret or rfi, then BSPSTORE 
>>is located above BSP.
>>    
>>
>RSE.BOF by definition ends up in the current partition (which is
>immediately dirty), which is above the other dirty registers (if any) in
>the dirty partition, which is above the clean partition.  Hence in the
>normal case BSPSTORE is less than or equal to BSP.
>
It looks to me like the clean partition only exists in the high level 
IA64 architecture design. The clean partition is probably lacking in the 
Intel reference models as well as in current hardware designs. So the 
documentation does not care a lot about the clean partition and leaves 
it up to the phantasy of the reader what happens to it in the case of a 
br.ret or rfi.

>Hope this helps, feel free to argue with me if you disagree.
>
Your idea of treating all former clean regs as current dirty regs and so 
logically flushing the clean parition is exactly the way I solved the 
issue in our simulator.

Thanks

Christian


____________
Virus checked by G DATA AntiVirusKit


