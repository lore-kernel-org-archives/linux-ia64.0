From: edwardsg@sgi.com (Greg Edwards)
Date: Tue, 11 May 2004 16:39:31 +0000
Subject: Re: [PATCH] set EXEC_PAGESIZE to PAGE_SIZE
Message-Id: <20040511163931.GB24203@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040511145923.GC23495@sgi.com>
In-Reply-To: <20040511145923.GC23495@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 11, 2004 at 06:24:22PM +0200, Andreas Schwab wrote:
| edwardsg@sgi.com (Greg Edwards) writes:
| 
| > The number of pages allocated for the gid_t * blocks[] array in the
| > group_info struct is calculated from EXEC_PAGESIZE.  This is used when
| > the number of groups goes above 32.  On ia64, this is currently
| > hard-coded at 65536, which results in only a 1/4 of the required pages
| > being allocated on a 16k page size kernel.  A setgroups() call with a
| > gidsetsize of 65536 will end up tromping on memory.  Patch below sets
| > EXEC_PAGESIZE to PAGE_SIZE.
| 
| IMHO the real bug is that EXEC_PAGESIZE is used in the first place.
| EXEC_PAGESIZE is supposed to be the biggest page size supported by any
| executable, thus is should always be the max of all possible page sizes.
| It has no relation to the actual page size of the running kernel.

Thanks for pointing that out, Andreas.  I'll take a look and see if any
arches have a problem with calculating NGROUPS_PER_BLOCK from
PAGE_SIZE instead of EXEC_PAGESIZE, then I'll send something to lkml.

Greg
