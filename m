From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Sun, 06 Aug 2006 22:54:51 +0000
Subject: Re: question: TLB sharing between child processes
Message-Id: <873bc9a30k.wl%peterc@gelato.unsw.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <AB3F23D36A977945B3F991A27D4CB64F02D1D3E4@ms09.mse4.exchange.ms>
In-Reply-To: <AB3F23D36A977945B3F991A27D4CB64F02D1D3E4@ms09.mse4.exchange.ms>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Sanjay" = Sanjay Bhandari <sbhandari@dataupia.com> writes:

Sanjay> (If this is the wrong forum for this question, a pointer to
Sanjay> the right one will be appreciated)
 
Sanjay> What can I expect in terms of TLB and cache sharing between
Sanjay> different processes when they are all non-exec'ed children of
Sanjay> the same parent (i.e. fork but no exec)?

There is no TLB sharing in standard Linux.  Matt Chapman had a patch
that enabled TLB sharing for memory regions with the same protections
and virtual address in different address spaces; benchmarking showed a
very large reduction in ITLB misses, but lesser reduction in DTLB
misses (COW means that data areas are not actually shared).  Overall,
ITLB misses weren't a big enough factor in the workloads we had
to make a real difference.  If you had a workload that had a large
shared memory region mapped into the same address in multiple
processes, the tradeoffs may differ.

Itanium caches are physically mapped, so they are always shared.

--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

