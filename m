From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Wed, 08 Dec 2004 19:07:27 +0000
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-Id: <140570000.1102532847@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain><Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com><Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org><Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com><Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org><Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com><Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org> <41AEB44D.2040805@pobox.com><20041201223441.3820fbc0.akpm@osdl.org> <41AEBAB9.3050705@pobox.com><20041201230217.1d2071a8.akpm@osdl.org> <179540000.1101972418@[10.10.2.4]><41AEC4D7.4060507@pobox.com> <20041202101029.7fe8b303.cliffw@osdl.org> <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> The page fault handler for anonymous pages can generate significant overhead
> apart from its essential function which is to clear and setup a new page
> table entry for a never accessed memory location. This overhead increases
> significantly in an SMP environment.
> 
> In the page table scalability patches, we addressed the issue by changing
> the locking scheme so that multiple fault handlers are able to be processed
> concurrently on multiple cpus. This patch attempts to aggregate multiple
> page faults into a single one. It does that by noting
> anonymous page faults generated in sequence by an application.
> 
> If a fault occurred for page x and is then followed by page x+1 then it may
> be reasonable to expect another page fault at x+2 in the future. If page
> table entries for x+1 and x+2 would be prepared in the fault handling for
> page x+1 then the overhead of taking a fault for x+2 is avoided. However
> page x+2 may never be used and thus we may have increased the rss
> of an application unnecessarily. The swapper will take care of removing
> that page if memory should get tight.
> 
> The following patch makes the anonymous fault handler anticipate future
> faults. For each fault a prediction is made where the fault would occur
> (assuming linear acccess by the application). If the prediction turns out to
> be right (next fault is where expected) then a number of pages is
> preallocated in order to avoid a series of future faults. The order of the
> preallocation increases by the power of two for each success in sequence.
> 
> The first successful prediction leads to an additional page being allocated.
> Second successful prediction leads to 2 additional pages being allocated.
> Third to 4 pages and so on. The max order is 3 by default. In a large
> continous allocation the number of faults is reduced by a factor of 8.
> 
> The patch may be combined with the page fault scalability patch (another
> edition of the patch is needed which will be forthcoming after the
> page fault scalability patch has been included). The combined patches
> will triple the possible page fault rate from ~1 mio faults sec to 3 mio
> faults sec.
> 
> Standard Kernel on a 512 Cpu machine allocating 32GB with an increasing
> number of threads (and thus increasing parallellism of page faults):

Mmmm ... we tried doing this before for filebacked pages by sniffing the
pagecache, but it crippled forky workloads (like kernel compile) with the 
extra cost in zap_pte_range, etc. 

Perhaps the locality is better for the anon stuff, but the cost is also
higher. Exactly what benchmark were you running on this? If you just run
a microbenchmark that allocates memory, then it will definitely be faster.
On other things, I suspect not ...

M.



