From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 28 Feb 2005 20:07:46 +0000
Subject: RE: [Patch 3/3] Shrink page table quicklist based on free memory.
Message-Id: <200502282007.j1SK7ig13891@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142716.GG10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142716.GG10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Saturday, February 26, 2005 6:27 AM
> This patch shrinks the quicklist based upon free memory on the node
> instead of the high/low water marks.  I also limit the rate of drain from
> the quicklist by 256 entries per pass.  The limit was placed because this
> freeing is done with the preemption disabled and large frees have caused
> unexpected bubbles in latency.  The 256 was chosen based on some test
> runs which showed blips above the noise range with 4096 pages and that 256
> pages resulted in the least amount of overshoot as processes were exiting.
> Typical response at 128 would be periodic freeing of pages followed by
> allocating at next startup.  With 256, this was nearly never observed.

I'm not a huge fan of hooking memory free function in idle loop.  It's a
broken model.  They enlarge wake up latency, pollutes caches, slows the
system down.  Why can't this be done on demand under memory pressure?

- Ken


