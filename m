From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 29 Mar 2012 09:58:49 +0000
Subject: Re: [PATCH] IRQ: normalize chip->irq_set_affinity return value on x86 and IA64
Message-Id: <alpine.LFD.2.02.1203291154010.2542@ionos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1331046112-19526-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1331046112-19526-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <liuj97@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jes Sorensen <jes@sgi.com>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Yinghai Lu <yinghai@kernel.org>, Thomas Meyer <thomas@m3y3r.de>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-altix@sgi.com, x86@kernel.org, chenkeping@huawei.com

On Tue, 6 Mar 2012, Jiang Liu wrote:

> On x86 and IA64 platforms, interrupt controller chip's irq_set_affinity()
> method always copies affinity mask to irq_data->affinity field but still
> returns 0(IRQ_SET_MASK_OK). That return value causes the interrupt core
> logic unnecessarily copies the mask to irq_data->affinity field again.
> So return IRQ_SET_MASK_OK_NOCOPY instead of IRQ_SET_MASK_OK to get rid of
> the duplicated copy operation.
> 
> This patch applies to v3.3-rc6 and has been tested on x86 platforms.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>  arch/ia64/kernel/iosapic.c     |    4 +++-
>  arch/ia64/kernel/msi_ia64.c    |    4 ++--
>  arch/ia64/sn/kernel/irq.c      |    2 +-
>  arch/ia64/sn/kernel/msi_sn.c   |    2 +-
>  arch/x86/kernel/apic/io_apic.c |   11 ++++++-----
>  arch/x86/platform/uv/uv_irq.c  |    2 +-
>  kernel/irq/internals.h         |    3 +++
>  kernel/irq/manage.c            |   39 ++++++++++++++++++++++-----------------
>  kernel/irq/migration.c         |    6 +-----


This does not work that way. The patch wants to be split in 3 parts
(core, x86, ia64). The patches are completely independent. Please
resend.

Thanks,

	tglx
