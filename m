From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 08 Jun 2006 22:47:59 +0000
Subject: Re: [Fastboot] Ia64 kdump patch
Message-Id: <1149806879.2591.180.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2006-06-08 at 16:35, Horms wrote:
> On Thu, Jun 08, 2006 at 06:48:23AM +0800, Zou Nan hai wrote:
> > The ia64 kdump patch is in 2 parts.
> > 
> > the kexec-kdump-ia64-2.6.16.patch should apply on top of the previous 
> > kexec patch by Khalid in Tony's test tree.
> > 
> > the kexec-tools-kdump-ia64.patch should apply to kexec-tools-1.101
> > with kexec-tools-1.101-kdump.patch
> > 
> > 
> > To test it.
> > Build first SMP kernel with KEXEC and KDUMP enabled.
> > 
> > Boot it with kernel parameter "crashkernel=XXX@YYY"
> > means reserver XXX from YYY for crashdumping.
> > Build an UP kernel with KEXEC KDUMP VMCORE enabled.
> > load this kernel as a crashdumping kernel
> > kexec -p vmlinux.gz --initrd=initrd --append="...."
> > 
> > trigger a crash,
> > maybe "echo c > /proc/sysrq-trigger"
> > after the crash kernel boots,
> > cp /proc/vmcore core
> > 
> > gdb first_kernel_vmlinux core
> > 
> > please test and review.
> > 
> > Signed-off-by: Khalid Aziz <khalid_aziz@hp.com>
> > Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
> Hi,
> 
> I'm very excited to be able to play with the new version of this patch,
> but the version you posted seems to included include all the kexec patch
> that went into Tony Luck's tree. Here is a rediff relative to the
> existing kexec patch (no other changes).
> 
> The code does seem to be working for me. The main difficulty so far
> seems to have been finding an appropriate place and size and place for
> the reserved area. 128M@256M seems to work for me, offering enough
> memory and not lie on a resource boundry for me.
> 
> Lastly, is it possible for you to comment on what areas of concern
> you have with regards to kdump/kexec on ia64. I am looking to port this
> code to xen, as my colleague Magnus Damm and I have already done so for i386
> (complete) and x86_64 (almost complete).
> 
> http://lists.xensource.com/archives/html/xen-devel/2006-05/msg01272.html
> 
> Signed-Off-By: Horms <horms@verge.net.au>
> 

 Thanks for testing and review.
 
 There is still a lot of work to do for ia64 Kdump to be a very useful
and robust feature.

 Major issues.
 1. Full percpu dumping on INIT. 
    You may notices I only send an IPI to user CPUs and dump part of
registers for crashing CPU.Just stop other CPUs, not dumping their
status. This is only a temp hack.
 On other platforms they did this by an NMI, on IA64 we should use INIT
to acknowledge other CPUs. And I know on some platform there is a
trigger on panel can trigger INIT. We could use that to dump at the time
of deadlock. But currently INIT is used by MCA, we need to find a way to
coordinate with MAC on INIT.

 2. unwind section is missing in vmcore.
    When you do a readelf on vmcore, you may notice there is no unwind
sections. We should add this percpu stack unwind sections to help dump
filter tools to analize the core dump.

 3. kdump path at crash time. 
    Currently I still have to do a irq->end on each level triggered irq,
without that the MPT fusion driver can not restart. We should fix this,
at least do that in a way of not touching any memory in previous kernel.

 4. Other than this, we need port the dump filter to IA64.

There are still some minor issues.
e.g
  When I get a crash when X is active, the new kernel will startup in a
blank screen(network is still working). I have indeed do a brute force
VGA reset on in purgatory code. But that seems to only shutdown the VGA
but not reinit it if X is running.

  Current kexec can't not run on a kexec'd kernel, that is because the
memory region of EFI memmap is not reserverd in /proc/iomem, I will sent
a patch to reserve that region later.

There should be other issues and gaps need to find out.

Thanks
Zou Nan hai
