From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 12 Jun 2006 00:16:06 +0000
Subject: Re: [Fastboot] Ia64 kdump patch
Message-Id: <1150071366.2591.204.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2006-06-12 at 09:50, Takao Indoh wrote:
> On 09 Jun 2006 06:47:59 +0800, Zou Nan hai wrote:
> 
> > Thanks for testing and review.
> > 
> > There is still a lot of work to do for ia64 Kdump to be a very useful
> >and robust feature.
> >
> > Major issues.
> > 1. Full percpu dumping on INIT. 
> >    You may notices I only send an IPI to user CPUs and dump part of
> >registers for crashing CPU.Just stop other CPUs, not dumping their
> >status. This is only a temp hack.
> > On other platforms they did this by an NMI, on IA64 we should use INIT
> >to acknowledge other CPUs. And I know on some platform there is a
> >trigger on panel can trigger INIT. We could use that to dump at the time
> >of deadlock. But currently INIT is used by MCA, we need to find a way to
> >coordinate with MAC on INIT.
> >
> > 2. unwind section is missing in vmcore.
> >    When you do a readelf on vmcore, you may notice there is no unwind
> >sections. We should add this percpu stack unwind sections to help dump
> >filter tools to analize the core dump.
> >
> > 3. kdump path at crash time. 
> >    Currently I still have to do a irq->end on each level triggered irq,
> >without that the MPT fusion driver can not restart. We should fix this,
> >at least do that in a way of not touching any memory in previous kernel.
> >
> > 4. Other than this, we need port the dump filter to IA64.
> >
> >There are still some minor issues.
> >e.g
> >  When I get a crash when X is active, the new kernel will startup in a
> >blank screen(network is still working). I have indeed do a brute force
> >VGA reset on in purgatory code. But that seems to only shutdown the VGA
> >but not reinit it if X is running.
> >
> >  Current kexec can't not run on a kexec'd kernel, that is because the
> >memory region of EFI memmap is not reserverd in /proc/iomem, I will sent
> >a patch to reserve that region later.
> >
> >There should be other issues and gaps need to find out.
> >
> >Thanks
> >Zou Nan hai
> >-
> >To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Hi, 
> 
> I tried to use kdump on ia64, and it seemed to work, but
> I was not able to execute back trace for the panic process using
> crash tool.
> 
> I think the reason is that 1st kernel does not save switch stack before
> 2nd kernel boots.
> 
> Do you have a plan to improve kdump to save switch stack?
> Or is there another method to trace panic process?
> 
  Yes, I am going to dump per-cpu unwind sections to the core file.

  Thanks
  Zou Nan hai
> Regards,
> Takao Indoh
