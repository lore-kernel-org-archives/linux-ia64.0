From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 10 Mar 2004 19:35:47 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <404F6E13.3030109@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> Assuming the patch is clean and the performance impact is reasonably
> small (I think it should be), I'm sure the patch would be welcome
> (that's just my opinion; Arun is the ia32 subsystem maintainer so he's
> the final decision maker as far as this is concerned).

Yes, I'd really like to see this problem fixed. I think, the patch needs to be as memory efficient as possible - we're using non-pageable kernel memory. So some numbers on the two level bitmap scheme vs keeping lists of head/tail pages for common ia32 workloads would be good.

    -Arun 
