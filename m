From: Matthew Dobson <colpatch@us.ibm.com>
Date: Tue, 29 Oct 2002 23:55:15 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] topology for ia64
Message-Id: <marc-linux-ia64-105590709805289@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805203@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805203@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Michael Hohnbaum wrote:
> On Tue, 2002-10-29 at 14:19, Matthew Dobson wrote:
> 
>>Erich Focht wrote:
>>+/*
>>+ * Returns the number of the first CPU on Node 'node'.
>>+ * Slow in the current implementation.
>>+ * Who needs this?
>>+ */
>>+/* #define __node_to_first_cpu(node) pool_cpus[pool_ptr[node]] */
>>+static inline int __node_to_first_cpu(int node)
>>
>>No one is using it now.  I think that I will probably deprecate this 
>>function in the near future as it is pretty useless.  Anyone looking for 
>>that functionality can just do an __ffs(__node_to_cpu_mask(node)) 
>>instead, and hope that there is a reasonably quick implementation of 
>>__node_to_cpu_mask.
> 
> I'm using this in the simple NUMA scheduler.  This is quite useful
> for iterating through a specific node's CPUs.  Yes, the functionality
> can be obtained in a different manner, but is less obvious.

Hmmm...  This is true, but I'd like to keep the topology functions as 
minimal as possible.  Since the functionality is so easily duplicated, 
and in almost every arch, is implemented almost identically, it seems a 
waste.  In most architectures, they itterate across cpus, either 
returning the first one on the node, or adding each to a mask and 
returning that.

Besides, it's not gone yet... ;)

Cheers!

-Matt


