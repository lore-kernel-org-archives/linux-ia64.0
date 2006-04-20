From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 20 Apr 2006 17:13:56 +0000
Subject: Re: [PATCH 3/5] Remove redundant NULL checks before [kv]free - in  arch/
Message-Id: <20060420171356.GA19088@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200604170328.42599.jesper.juhl@gmail.com>
In-Reply-To: <200604170328.42599.jesper.juhl@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Erich Focht <efocht@ess.nec.de>, linux-ia64@vger.kernel.org, eranian@hpl.hp.com, davidm@hpl.hp.com, Ben Herrenschmidt <benh@kernel.crashing.org>, paulus@samba.org, Jeff Dike <jdike@karaya.com>, user-mode-linux-devel@lists.sourceforge.net, Jan Engelhardt <jengelh@linux01.gwdg.de>

On Mon, Apr 17, 2006 at 03:28:42AM +0200, Jesper Juhl wrote:
> Remove redundant NULL checks before [kv]free + small CodingStyle cleanup
> for arch/
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> ---
> 
>  arch/ia64/kernel/topology.c               |    7 --
>  arch/ia64/sn/kernel/xpc_partition.c       |    8 --

Applied ia64 pieces.  Thanks.

>  arch/powerpc/platforms/powermac/low_i2c.c |    3
>  arch/um/kernel/irq.c                      |   93 +++++++++++++++---------------
>  arch/um/os-Linux/irq.c                    |   47 +++++++--------

These bits left to fend for themselves in patchspace.

-Tony
