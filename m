From: Robin Holt <holt@sgi.com>
Date: Wed, 09 Nov 2005 14:29:49 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051109142949.GB17866@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 07, 2005 at 01:18:37PM -0800, Luck, Tony wrote:
> >Another thing: has people tested 4 level page table with 4GB hugetlb page
> >size?  Looks like pud is already falling short on bits and entire pgd bits
> >will be falling off the 64-bit.  128-bit computing anybody? (just kidding).
> 
> I didn't try 4GB huge page ... but I did just try to build with
> a 64K normal page, and the build failed with fatal errors in ivt.S
> because of attempts to shift by more than 64.  There are also
> a gazillion[1] warnings about "left shift count >= width of type"
> from all over the build.
> 
> Perhaps arch/ia64/Kconfig shouldn't let you choose 4-level tables
> with a 64K pagesize?

I have this compiling now with 3 or 4 page table levels.  Given that
4 levels with 64k pages results in only having 1/8 of the page used,
I think I am going to get rid of my desire to not have this configurable
(I will merge the two patches together into one).

I still think that 4 level is probably a reasonable default.  With all the
benchmarks I ran, the difference remains in the noise range.  Worst case
change is approx 0.3% change in microbenchmarks with approx 2% noise.
Many have less that 0.1% change.  That seems reasonable.


As for larger page sizes, those config options seem to be removed.
How would you normally go about doing a 4GB huge page?  Is there more
to it than adding the config option back in?

With the latest changes I made to ivt.S, my 3-level selection no longer
boots so I will delay posting until I have that working.

Thanks,
Robin Holt
