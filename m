From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 06 Aug 2004 14:54:51 +0000
Subject: Re: [2.6.7, ia64] continual memory leak at ~102kB/s...
Message-Id: <20040806145451.GI17188@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20029.1091803458@www55.gmx.net>
In-Reply-To: <20029.1091803458@www55.gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Blueman <daniel.blueman@gmx.net>
Cc: linux-ia64@vger.kernel.org, davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org

On Fri, Aug 06, 2004 at 04:44:18PM +0200, Daniel Blueman wrote:
> When running 2.6.7 on a generic ia64 system, I see memory being leaked in
> the kernel. Most of the fancy (preempt, hot-plug procs, ...) features are
> disabled, and the system in a quiescent state [1].
> /proc/meminfo shows the memory as unaccounted for [2], so it seems likely it
> has been kmalloc()d somehere. A small script shows memory disappearing at
> 102kB/s [3].
> Anyone else seen this on ia64?

Could you dump /proc/slabinfo?


-- wli
