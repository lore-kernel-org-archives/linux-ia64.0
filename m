From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 24 Aug 2004 18:25:56 +0000
Subject: Re: [PATCH] fix generic build when CONFIG_SMP=n
Message-Id: <200408241125.56470.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131559.59229.jbarnes@engr.sgi.com>
In-Reply-To: <200408131559.59229.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, August 13, 2004 3:59 pm, Jesse Barnes wrote:
> This patch fixes the issues I saw with CONFIG_SMP=n when building a generic
> kernel with CONFIG_NUMA=y and CONFIG_DISCONTIGMEM=y.  It's still pretty
> rough, but I'd appreciate comments and testing on other platforms.  The
> per-cpu fixes are still pretty ugly--I'm sure I'm missing something that
> would make abstracting out per_cpu(cpu_info, cpu).node_data > mem_data[node].node_data much nicer looking.
>
> Fixing the build of generic kernels w/o CONFIG_NUMA or CONFIG_DISCONTIGMEM
> is left as an exercise for the reader. :)

No comments?  Tony, do you think it's ready to apply?

Thanks,
Jesse
