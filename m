From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 22 Apr 2003 20:39:38 +0000
Subject: Re: [Linux-ia64] [PATCH] move mmu_gathers into local_cpu_data
Message-Id: <marc-linux-ia64-105590723705586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 22, 2003 at 02:23:31PM -0400, Martin Hicks wrote:
> 
> Hi,
> 
> This is a patch that moves mmu_gathers into local_cpu_data on IA64 NUMA.
> I'm not exactly sure where to push this patch, because it does touch
> include/asm-generic/tlb.h although it has no effect on non ia64 arches.
> 
> The main reason for making this change is that the mmu_gathers array
> gets very large as the number of processors increases.

For 2.5 please just make mmu_gathers per-cpu data for all arches.


