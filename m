From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 30 Mar 2006 18:26:23 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on
Message-Id: <1143743183.9731.84.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2006-03-30 at 10:18 -0800, Luck, Tony wrote:
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

Instead of tacking on yet another hack to vmem_map[], is this perhaps a
time to think about moving to sparsemem on systems where you see these
issues?  Are there remaining issues that ia64 has with it? 

-- Dave

