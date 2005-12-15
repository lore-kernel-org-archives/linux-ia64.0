From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 15 Dec 2005 21:59:21 +0000
Subject: Re: [Perfctr-devel] 2.6.15-rc5-git3 perfmon2 new code base + libpfm available
Message-Id: <20051215215921.GJ18331@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215104604.GA16937@frankl.hpl.hp.com> <43A1DE94.8050105@redhat.com>
In-Reply-To: <43A1DE94.8050105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@redhat.com>
Cc: perfctr-devel@lists.sourceforge.net, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Will,


On Thu, Dec 15, 2005 at 04:22:28PM -0500, William Cohen wrote:
> Stephane Eranian wrote:

> >I have released a new version of the perfmon base package.
> >This release is relative to 2.6.15-rc5-git3.
> >
> >I have also updated the library, libpfm-3.2, to match the kernel
> >level changes. 
> 
> I downloaded the new version of perfmon and the matching libpfm. I built 
> everything on a p6 based machine. The kernel booted fine. I tried the 
> task_smpl_user in the libpfm examples. That crashed the kernel. What was 
> on the xterm:
> 
> $ ./task_smpl_user ls
> measuring at plm=0x8
> programming 2 PMCS and 2 PMDS
> Segmentation fault
> 
I have not tried this particular test program in a long time. I nfact, I would
like to remove it from the suite because it does not make any real sense.
In any case, it should not crash the kernel. I will investigate this.
I don't think it it related to you using a P6. This is more the case of
an error in the cleanup code in case the context cannot be created properly.

Does task_smpl work properly?


> snd_hwdep snd_timer emu10k1_gp snd gameport soundcore snd_page_alloc 
> Dec 15 15:54:40 trek kernel: EIP is at pfm_smpl_fmt_put+0x11/0x60
> Dec 15 15:54:40 trek kernel: Call Trace:
> Dec 15 15:54:40 trek kernel:  [<c0201ee7>] __pfm_create_context+0x167/0x440
> Dec 15 15:54:40 trek kernel:  [<c010400c>] __switch_to+0x15c/0x220
> Dec 15 15:54:40 trek kernel:  [<c0203f98>] sys_pfm_create_context+0x78/0xe0
> Dec 15 15:54:40 trek kernel:  [<c010569d>] syscall_call+0x7/0xb

Thanks.

-- 
-Stephane
