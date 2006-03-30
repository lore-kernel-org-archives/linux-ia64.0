From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 30 Mar 2006 19:24:34 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <200603301923.k2UJNmg23124@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, March 30, 2006 10:19 AM
> > What about the earlier proposal of advancing at pmd and pud granule by
> > walking the page table?  There it can walk at 32MB/64GB step.
> 
> That puts constraints on where the platform may align physical
> memory.  32M may not be unreasonable (Can you even buy DIMMS that
> small anymore?) But 64G is way too large.
> 
> Since we only deal with blocks of memory in IA64_GRANULE_SIZE
> pieces (16M or 64M) that would seem to be the natural skip
> amount.

I don't mean to walk unconditionally at 32MB or 64GB granule.  What I
proposed earlier is to look at page table of vmem_map and find next
none-zero pte.  If you know some of the pmd are not present, then one
can skip the entire pte page (or 2048 pages, hence the 32MB of virtual
address space used by vmem_map, the actual memory represent by 32MB
vmem_map space is a lot bigger than that!). Same apply to pud, i.e.,
pud not present meaning the entire 64GB of virtual address space used
by vmem_map is empty.

Of course, when you find a none-zero entry in pud, one the drill down
to next none-zero pmd, and so on so forth.  The loop then popping back
up upon hitting a none-zero pte.

- Ken
