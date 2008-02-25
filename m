From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 25 Feb 2008 04:18:15 +0000
Subject: Re: [PATCH 0/4] ia64/xen: paravirtualization of hand written assembly code
Message-Id: <2352.1203913095@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <12039094061834-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12039094061834-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata (on Mon, 25 Feb 2008 12:16:42 +0900) wrote:
>Hi. The patch I send before was too large so that it was dropped from
>the maling list. I'm sending again with smaller size.
>This patch set is the xen paravirtualization of hand written assenbly
>code. And I expect that much clean up is necessary before merge.
>We really need the feed back before starting actual clean up as Eddie
>already said before.
>
>Eddie discussed how to clean up and suggested several ways.
>  1: Dual IVT source code, dual IVT table. (The way this patch set adopted)
>  2: Same IVT source code, but dual/mulitple compile to generate
>     dual/multiple IVT table using assembler macro.
>  3: Single IVT table, using indirect function call for pv_ops using
>     branch/binary patching.
>
>At this moment my preference is the option 2. Please comment.

A combination of options (2) and (3) would work.  Have a single source
file for the IVT, using conditional macros.  Use that source file to
build (at least) two copies of the IVT, for native and any virtualized
modes.  The native copy of the IVT starts at label ia64_ivt in section
.text.ivt, as it does now.  Any IVT versions for virtualized mode are
defined as __cpuinitdata, so they are discarded after boot, unless
CONFIG_HOTPLUG_CPU=y.  arch/ia64/kernel/head.S copies the relevant
virtualized version over ia64_ivt when necessary, before initializing
cr.iva.

Single source for maintenance.  No indirect function overhead at run
time.  Binary patching at boot time for the right mode.  No wasted
space in the kernel.

