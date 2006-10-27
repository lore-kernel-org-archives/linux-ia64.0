From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 27 Oct 2006 00:25:11 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <454151E7.8010102@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All right. Thank you, Russ.

- H.Seto

Acked-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

Russ Anderson wrote:
> It's worth noting that this change does not effect the selection of
> which process to kill.  It only effects which physical memory
> address gets marked as bad.  
> 
> In my test case, a correctable error is injected (an ends up in the
> bus check target identifier) then a memory uncorrectable is injected
> and consumed, triggering the MCA.  The test program is correctly 
> terminated, but the current code uses the bus check target identifier
> and marks the address of the correctable error as bad.  The real bad
> memory goes back on the free list, and promptly gets reused, triggering
> another MCA.  The cycle repeats until the kernel happens to get
> the memory.  Kernel memory error, end of ballgame.

