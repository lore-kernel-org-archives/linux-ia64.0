From: Rohit Seth <rohit.seth@intel.com>
Date: Tue, 08 Nov 2005 18:56:45 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <1131476206.2400.33.camel@akash.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-11-08 at 06:43 -0600, Robin Holt wrote:
> On Mon, Nov 07, 2005 at 04:22:32PM -0800, Rohit Seth wrote:
> > I think using a 64K page size (may be make that default for IA-64 or
> > distribute as another kernel the way SuSE has done) is preferred over
> > 4-level page tables....particularly for big memory machines.
> 
> For your particular application, that may be the case.  For approx half
> of our customers, they _REQUIRE_ their application be certified by the
> software vendor.  The vendors usually try to limit their exposure by
> certifiying on the smallest set kernel/modules/libraries possible.
> We don't control that.
> 

I agree with you completely about OSV certification part.  And SuSE is
again a good example here, they have a released kernel with 64K page
size.  There is no reason why end customer should not be using this
bigger page kernel when desired.

> > There is always at least couple of percentage points that an application
> > can gain with even smaller memory foot print (like few gig!) by using
> > 64K page size for normal pages.
> 
> There is also the possibility that the app may be using the pages sparsely
> and therefore wasting a larger percentage of time zeroing memory which
> is never needed (smaller percent of page fill).
> 

You are right that there is extra setup cost (+ some additional bloat)
coming with default 64K page size.  But there is additional cost
associated with 4-level page tables too(some of it in the critical
low-level fault handlers as well). 

I just think that we should validate the 64K page size more rigorously.
So as to have the OSVs gain more confidence.  There is such a wide range
of system configurations...having a single kernel configuration may not
be the optimal solution.


Thanks,
-rohit

