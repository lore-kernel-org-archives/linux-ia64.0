From: Andrew Morton <akpm@osdl.org>
Date: Thu, 08 Apr 2004 22:47:42 +0000
Subject: Re: HUGETLB commit handling.
Message-Id: <20040408154742.3faf7141.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <15037082.1081445730@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <15037082.1081445730@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: kenneth.w.chen@intel.com, raybry@sgi.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Andy Whitcroft <apw@shadowen.org> wrote:
>
> We have been looking at the HUGETLB page commit issue (offlist) and are
> close a final merged patch.

Be aware that I've merged a patch from Bill which does all the hugetlb code
unduplication.  A thousand lines gone:

 25-akpm/arch/i386/mm/hugetlbpage.c    |  264 ----------------------------------
 25-akpm/arch/ia64/mm/hugetlbpage.c    |  251 --------------------------------
 25-akpm/arch/ppc64/mm/hugetlbpage.c   |  257 ---------------------------------
 25-akpm/arch/sh/mm/hugetlbpage.c      |  258 ---------------------------------
 25-akpm/arch/sparc64/mm/hugetlbpage.c |  259 ---------------------------------
 25-akpm/fs/hugetlbfs/inode.c          |    2 
 25-akpm/include/linux/hugetlb.h       |    7 
 25-akpm/kernel/sysctl.c               |    6 
 25-akpm/mm/Makefile                   |    1 
 25-akpm/mm/hugetlb.c                  |  245 +++++++++++++++++++++++++++++++
 10 files changed, 263 insertions(+), 1287 deletions(-)

Of course, this buggers up everyone else's patches, but I do think this
work has to come first.

I still need to test this on ppc64 and ia64.  I've dropped a rollup against
2.6.5 at http://www.zip.com.au/~akpm/linux/patches/stuff/mc3.bz2 which you
should work against until I get -mc3 out for real.

