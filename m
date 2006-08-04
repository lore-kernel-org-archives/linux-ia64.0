From: "Sanjay Bhandari" <sbhandari@dataupia.com>
Date: Fri, 04 Aug 2006 01:44:03 +0000
Subject: question: TLB sharing between child processes
Message-Id: <AB3F23D36A977945B3F991A27D4CB64F02D1D3E4@ms09.mse4.exchange.ms>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(If this is the wrong forum for this question, a pointer to the right
one will be appreciated)
 
What can I expect in terms of TLB and cache sharing between different
processes when they are all non-exec'ed children of the same parent
(i.e. fork but no exec)?

The architecture is IA64. 

I am trying to get some insight into the context switch overhead for
this scenario. My understanding is that the processes will COW share the
physical pages - but have been unable to get a clear read on how things
fare with the TLB and caches. If the virtual addresses in each process
point to the same physical addresses, do they share the TLB and cache
entries - or do they have to allocate separate ones (given that the
entries are tagged with ASN etc.)?

Any pointers will be much appreciated.
