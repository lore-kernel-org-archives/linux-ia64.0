From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Tue, 06 Aug 2002 20:26:12 +0000
Subject: Re: [Linux-ia64] Re: CPU hotplug boot change for IA64
Message-Id: <marc-linux-ia64-105590701905919@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Erich,

On Tue, 6 Aug 2002 20:33:09 +0200
Erich Focht <efocht@ess.nec.de> wrote:

> > I removed cpu_initialized and fixed several bugs.
> > I tested SMP and UP kernels on 2-way Bigsur.
> > Please let me know if there is any problem on the patch.
> 
> The patch looks fine. Before applying it to 2.5.29 my BigSur ended up
> with no tasks beeing scheduled to cpu#1 and no migration_task and
> ksoftirqd for the same cpu. But the system came up. After applying it 
> the system hangs in the boot sequence right after "Freeing unused
> kernel memory". But CPU#1 was woken up correctly. Sorry, have no kdb
> to be able to tell you more...
> 
> Does anybody else have these problems?

I had a problem that the system hang at booting on 2.5.29 without
my patch. After that, I turned off CONFIGs as much as possible
and then I succeeded to boot the kernel.
I suspect IDE/ATAPI driver or something was causing the problem
(I'm not sure, though.)
Anyway, I'd like to reproduce the problem. Could you send me your
.config?

Regards,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


