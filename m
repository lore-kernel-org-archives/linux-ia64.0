From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 20 Nov 2019 08:46:12 +0000
Subject: Re: [PATCH 04/12] ia64: Replace cpu_down with freeze_secondary_cpus
Message-Id: <alpine.DEB.2.21.1911200944590.6731@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191030153837.18107-1-qais.yousef@arm.com> <20191030153837.18107-5-qais.yousef@arm.com> <alpine.DEB.2.21.1911192318400.6731@nanos.tec.linutronix.de> <20191119223234.ov323rcln4slj7br@e107158-lin.cambridge.arm.com>
 <alpine.DEB.2.21.1911192344110.6731@nanos.tec.linutronix.de> <20191119231912.viwqgcyzttoo5eou@e107158-lin.cambridge.arm.com>
In-Reply-To: <20191119231912.viwqgcyzttoo5eou@e107158-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qais Yousef <qais.yousef@arm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 19 Nov 2019, Qais Yousef wrote:
> On 11/19/19 23:59, Thomas Gleixner wrote:
> > On Tue, 19 Nov 2019, Qais Yousef wrote:
> > > My plan was to simply make freeze_secondary_cpus() available and protected by
> > > CONFIG_SMP only instead.
> > > 
> > > Good plan?
> > 
> > No. freeze_secondary_cpus() is really for hibernation. Look at the exit
> > conditions there.
> 
> Hmm do you mean the pm_wakeup_pending() abort?
> 
> In arm64 we machine_shutdown() calls disable_nonboot_cpus(), which in turn
> a wrapper around freeze_secondary_cpus() with 0 passed as an argument.
> 
> IIUC this means arm64 could fail to offline all CPUs on machine_shutdown(),
> correct?

Looks like.

Thanks,

	tglx
