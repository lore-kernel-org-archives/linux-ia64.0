From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 03 Nov 2005 01:53:10 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511030153.jA31rFg17650@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote on Wednesday, November 02, 2005 10:59 AM
> On 11/2/05, Robin Holt <holt@sgi.com> wrote:
> 
> > Does anybody have any objections to making 4 level the default?
> 
> My concern is that 4-level PT really isn't needed on ia64 for all but
> the largest machines

No kidding. People envy that I have a machine with 64 GB, 128 GB and I
envy Robin has access to machine with more than 16 TB.  How many average
joe is going to be able to afford machine like that?  Actually, how many
installation will there be in the entire world (100?, 1000?)


> so perhaps it's not a bad idea to make 4-level the
> default and see if anyone complains about performance regressions.

He he. What a nice way to kick people around for doing performance
measurement :-)

I just did a quick measurement with I/O submission path.  get_user_pages
is my biggest concern that extra level means more code and cache foot
print for each I/O submission.  It cost about 1.5% more in I/O path
length on a micro-benchmark (from block layer and Up).  This could be
all buried as noise in a larger scheme for industry database benchmark.

Another thing: has people tested 4 level page table with 4GB hugetlb page
size?  Looks like pud is already falling short on bits and entire pgd bits
will be falling off the 64-bit.  128-bit computing anybody? (just kidding).

- Ken

