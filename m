From: Robin Holt <holt@sgi.com>
Date: Mon, 12 Mar 2007 15:52:25 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070312155225.GB9388@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com> <20070311.135946.28788670.davem@davemloft.net> <Pine.LNX.4.64.0703120409150.25910@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703120409150.25910@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

On Mon, Mar 12, 2007 at 04:12:32AM -0700, Christoph Lameter wrote:
> On Sun, 11 Mar 2007, David Miller wrote:
> > The reason is that every time I've monitored the allocation patterns
> > of these things on SMP, the page table chunks always get released on a
> > different cpu than where they were initialized.
> 
> But its even advantageous in that case for sparse allocs.

We have a written a little LD_PRELOAD library which intercepts fork()
et. al. and migrates the task to a different cpu, pins itself to only
that cpu, then does the user requested call, upon return from the call,
the task is migrated back to the original cpu and the original allowed
cpus is restored.  With that library, we find a few advantages, mainly,
the task_struct and page tables are allocated node local to the task.
As long as the task does not change its allowed cpus mask, they are also
freed on the same cpu which allocated them.

Thanks,
Robin
