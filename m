From: Michael Hohnbaum <hohnbaum@us.ibm.com>
Date: Tue, 29 Oct 2002 22:35:28 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] topology for ia64
Message-Id: <marc-linux-ia64-105590709805287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805203@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805203@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2002-10-29 at 14:19, Matthew Dobson wrote:
> Erich Focht wrote:
> +/*
> + * Returns the number of the first CPU on Node 'node'.
> + * Slow in the current implementation.
> + * Who needs this?
> + */
> +/* #define __node_to_first_cpu(node) pool_cpus[pool_ptr[node]] */
> +static inline int __node_to_first_cpu(int node)
> 
> No one is using it now.  I think that I will probably deprecate this 
> function in the near future as it is pretty useless.  Anyone looking for 
> that functionality can just do an __ffs(__node_to_cpu_mask(node)) 
> instead, and hope that there is a reasonably quick implementation of 
> __node_to_cpu_mask.
> 
I'm using this in the simple NUMA scheduler.  This is quite useful
for iterating through a specific node's CPUs.  Yes, the functionality
can be obtained in a different manner, but is less obvious.

-- 

Michael Hohnbaum                      503-578-5486
hohnbaum@us.ibm.com                   T/L 775-5486


