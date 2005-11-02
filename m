From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Nov 2005 10:35:40 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051102103540.GB23973@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 01, 2005 at 07:41:26AM -0800, David Mosberger-Tang wrote:
> On 11/1/05, Robin Holt <holt@sgi.com> wrote:
> 
> > I am trying to get time on one of our larger machines today to run the
> > RandomAccess benchmark (as well as some help from somebody that has run
> > these before).  Is there a certain number of cpus you would like this
> > run on or is a 64p box adequate?
> 
> Oh, even a single CPU should be fine.  Just use a large working set. 
> IIRC, about 16GB should ensure that not even the page tables fit in
> the cache (depending on your cache-size, of course).

I have not been able to see any difference.  I am not sure what part of
the hpccoutf.txt file.  I think I should be looking at:

Begin of SingleRandomAccess section.
Main table size   = 2^27 = 134217728 words
Number of updates = 536870912
CPU time used  = 107.997328 seconds
Real time used = 108.077732 seconds
0.004967452 Billion(10^9) Updates    per second [GUP/s]
Found 0 errors in 134217728 locations (passed).
Node(s) with error 0
Node selected 0
Single GUP/s 0.004967
Current time (1130893857) is Tue Nov  1 19:10:57 2005

End of SingleRandomAccess section.


If so, this benchmark seems to have some unstable results.  I ran 10
iterations on a 3-level kernel and got:

CPU time used  = 128.912032 seconds
CPU time used  = 109.921024 seconds
CPU time used  = 170.240752 seconds
CPU time used  = 118.555696 seconds
CPU time used  = 107.986592 seconds
CPU time used  = 126.163616 seconds
CPU time used  = 110.157216 seconds
CPU time used  = 115.738960 seconds
CPU time used  = 107.997328 seconds
CPU time used  = 108.786912 seconds

Is this expected?

Thanks,
Robin
