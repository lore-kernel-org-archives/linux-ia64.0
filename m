From: Sinan Kaya <okaya@codeaurora.org>
Date: Wed, 28 Mar 2018 13:02:33 +0000
Subject: Re: [PATCH] docs/memory-barriers.txt: Fix broken DMA vs MMIO ordering example
Message-Id: <c93ed5db-8cfd-1258-3396-62ca2076c44d@codeaurora.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1522156287-15169-1-git-send-email-will.deacon@arm.com>
 <20180327150252.GN3675@linux.vnet.ibm.com>
In-Reply-To: <20180327150252.GN3675@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulmck@linux.vnet.ibm.com, Will Deacon <will.deacon@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Arnd Bergmann <arnd@arndb.de>, Jason Gunthorpe <jgg@ziepe.ca>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, linux-ia64@vger.kernel.org

+linux-ia64

On 3/27/2018 11:02 AM, Paul E. McKenney wrote:
> On Tue, Mar 27, 2018 at 02:11:27PM +0100, Will Deacon wrote:
>> The section of memory-barriers.txt that describes the dma_Xmb() barriers
>> has an incorrect example claiming that a wmb() is required after writing
>> to coherent memory in order for those writes to be visible to a device
>> before a subsequent MMIO access using writel() can reach the device.
>>
>> In fact, this ordering guarantee is provided (at significant cost on some
>> architectures such as arm and power) by writel, so the wmb() is not
>> necessary. writel_relaxed exists for cases where this ordering is not
>> required.
>>
>> Fix the example and update the text to make this clearer.
>>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Jason Gunthorpe <jgg@ziepe.ca>
>> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: Jonathan Corbet <corbet@lwn.net>
>> Reported-by: Sinan Kaya <okaya@codeaurora.org>
>> Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Good catch, queued on my lkmm branch, thank you!
> 
> 							Thanx, Paul
> 

Does IA64 follow this requirement? If not, is implementation planned?

"no wmb() before writel()"

Linus asked us to get rid of wmb() in front of writel() for UC memory.
Just checking that we are not breaking anything for IA64.

>> ---
>>  Documentation/memory-barriers.txt | 17 +++++++++--------
>>  1 file changed, 9 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
>> index a863009849a3..3247547d1c36 100644
>> --- a/Documentation/memory-barriers.txt
>> +++ b/Documentation/memory-barriers.txt
>> @@ -1909,9 +1909,6 @@ There are some more advanced barrier functions:
>>  		/* assign ownership */
>>  		desc->status = DEVICE_OWN;
>>
>> -		/* force memory to sync before notifying device via MMIO */
>> -		wmb();
>> -
>>  		/* notify device of new descriptors */
>>  		writel(DESC_NOTIFY, doorbell);
>>  	}
>> @@ -1919,11 +1916,15 @@ There are some more advanced barrier functions:
>>       The dma_rmb() allows us guarantee the device has released ownership
>>       before we read the data from the descriptor, and the dma_wmb() allows
>>       us to guarantee the data is written to the descriptor before the device
>> -     can see it now has ownership.  The wmb() is needed to guarantee that the
>> -     cache coherent memory writes have completed before attempting a write to
>> -     the cache incoherent MMIO region.
>> -
>> -     See Documentation/DMA-API.txt for more information on consistent memory.
>> +     can see it now has ownership.  Note that, when using writel(), a prior
>> +     wmb() is not needed to guarantee that the cache coherent memory writes
>> +     have completed before writing to the MMIO region.  The cheaper
>> +     writel_relaxed() does not provide this guarantee and must not be used
>> +     here.
>> +
>> +     See the subsection "Kernel I/O barrier effects" for more information on
>> +     relaxed I/O accessors and the Documentation/DMA-API.txt file for more
>> +     information on consistent memory.
>>
>>
>>  MMIO WRITE BARRIER
>> -- 
>> 2.1.4
>>
> 
> 


-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
