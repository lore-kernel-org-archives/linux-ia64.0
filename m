From: Rohit Seth <rohit.seth@intel.com>
Date: Tue, 08 Nov 2005 00:22:32 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <1131409352.20471.19.camel@akash.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-11-02 at 17:36 -0800, Gerald Pfeifer wrote:
> On Thu, 3 Nov 2005, Ian Wienand wrote: 
> > On Wed, Nov 02, 2005 at 11:16:11AM -0600, Robin Holt wrote: 
> > I must admit to be a bit perplexed however.  I would have thought
> that 
> > a customer who just spent (what I assume is a lot of) money on a 
> > machine to map huge areas of contiguous memory would really want to 
> > evaluate the probable benefits of larger pages, despite what Redhat 
> > ships.

Well, huge pages are not that easy to use...particularly if the app
source code can not be changed.

> 
> I'll note that SUSE has been shipping a 64k-pagesize kernel for more 
> than a year now as part of SUSE LINUX Enterprise Server 9, and I have 
> not seen a single L3 support call for this kernel.
> 
> Which means that it's either completely bug free, or nobody uses it 
> in production. ;-)
> 

I think using a 64K page size (may be make that default for IA-64 or
distribute as another kernel the way SuSE has done) is preferred over
4-level page tables....particularly for big memory machines.

There is always at least couple of percentage points that an application
can gain with even smaller memory foot print (like few gig!) by using
64K page size for normal pages.

-rohit

