From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 08 Nov 2003 08:39:21 +0000
Subject: Re: [PATCH preview] Adds nodemask_t for use in cpusets (NUMA memory placement)
Message-Id: <marc-linux-ia64-106828085509793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106825306926864@msgid-missing>
In-Reply-To: <marc-linux-ia64-106825306926864@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 07, 2003 at 03:14:15AM -0800, Paul Jackson wrote:
> # This patch includes the following deltas:
> #	           ChangeSet	1.1393  -> 1.1394 
> #	               (new)	        -> 1.1     include/asm-generic/nodemask_const_value.h
> #	               (new)	        -> 1.1     include/asm-generic/nodemask_arith.h
> #	               (new)	        -> 1.1     include/linux/nodemask.h
> #	               (new)	        -> 1.1     include/asm-generic/nodemask_smp.h
> #	               (new)	        -> 1.1     include/asm-generic/nodemask_const_reference.h
> #	               (new)	        -> 1.1     include/asm-generic/nodemask_array.h

Eek, can't you introduce a bitmap ADT that's used by both the cpumask
and nodemask?

