From: Matthew Dobson <colpatch@us.ibm.com>
Date: Wed, 30 Oct 2002 00:01:02 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] topology for ia64
Message-Id: <marc-linux-ia64-105590709805290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805203@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805203@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

William Lee Irwin III wrote:
> On Tue, Oct 29, 2002 at 02:19:25PM -0800, Matthew Dobson wrote:
> +/*
> + * Returns the number of the first CPU on Node 'node'.
> + * Slow in the current implementation.
> + * Who needs this?
> + */
> +/* #define __node_to_first_cpu(node) pool_cpus[pool_ptr[node]] */
> +static inline int __node_to_first_cpu(int node)
> 
> So far so safe... though no obvious use of it.

Yep...


> On Tue, Oct 29, 2002 at 02:19:25PM -0800, Matthew Dobson wrote:
> 
>>No one is using it now.  I think that I will probably deprecate this 
>>function in the near future as it is pretty useless.  Anyone looking for 
>>that functionality can just do an __ffs(__node_to_cpu_mask(node)) 
>>instead, and hope that there is a reasonably quick implementation of 
>>__node_to_cpu_mask.
> 
> 
> This assumes the value returned by __node_to_cpu_mask() is a single word.

Which is the case right now.  When (not if) that changes, we'll come up 
with more flexible ffs macros, or a better way to count variable length 
bitmasks...  especially as there will be a TON of them.

Cheers!

-Matt


