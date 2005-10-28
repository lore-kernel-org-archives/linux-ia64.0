From: Robin Holt <holt@sgi.com>
Date: Fri, 28 Oct 2005 11:19:29 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051028111929.GA28317@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 28, 2005 at 03:19:57PM +1000, Ian Wienand wrote:
> On Wed, Oct 26, 2005 at 11:17:09PM -0500, Robin Holt wrote:
> > I have started to work on 4-level page tables.  This boots.  I
> > make no further claims than that.
> 
> Do you need 4 level page tables for something?  I seem to remember it
> coming up before too, I'd certainly be interested in seeing any
> numbers you have.

We have an mpi library which makes memory available for multiple
processors.  We have squezzed as hard as we can to reduce the size of
that block.  Right now, the most processors we can service hits about
3192 (IIRC) which is more than enough for current hardware (limits to
2048 cpus).  In the next version of our hardware due out next spring,
that limit is raised to 16384 (IIRC).  To make the library work with
that size, we need to be able to mmap a larger region.

Unfortunately, we still want this to work with SUSE and RHEL
distributions.  Those distributors strongly favor a 16k page size.
To be able to use their standard kernel, we need to either convince the
entire community that 64k pages is right or we need to implement 4-level
page tables.

Thanks,
Robin
