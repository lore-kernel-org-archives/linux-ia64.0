From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 22 Apr 2003 21:22:19 +0000
Subject: Re: [Linux-ia64] [PATCH] move mmu_gathers into local_cpu_data
Message-Id: <marc-linux-ia64-105590723705587@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, Apr 22, 2003 at 09:39:38PM +0100, Christoph Hellwig wrote:
> On Tue, Apr 22, 2003 at 02:23:31PM -0400, Martin Hicks wrote:
> > 
> > Hi,
> > 
> > This is a patch that moves mmu_gathers into local_cpu_data on IA64 NUMA.
> > I'm not exactly sure where to push this patch, because it does touch
> > include/asm-generic/tlb.h although it has no effect on non ia64 arches.
> > 
> > The main reason for making this change is that the mmu_gathers array
> > gets very large as the number of processors increases.
> 
> For 2.5 please just make mmu_gathers per-cpu data for all arches.
> 

That was my intention.  For 2.4 my goal was "touch as little as
possible, and hopefully it will get accepted".

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

