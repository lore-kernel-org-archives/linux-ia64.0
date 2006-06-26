From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Mon, 26 Jun 2006 08:10:44 +0000
Subject: RE: [Fastboot] Ia64 kdump patch
Message-Id: <08B1877B2880CE42811294894F33AD5C053B56@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2006=C4=EA6=D4=C226=C8=D5 15:47
> To: Zou, Nanhai
> Cc: Linux-IA64; khalid_aziz@hp.com; fastboot@lists.osdl.org
> Subject: Re: [Fastboot] Ia64 kdump patch
>=20
> On Fri, Jun 09, 2006 at 06:47:59AM +0800, Zou Nan hai wrote:
> > On Thu, 2006-06-08 at 16:35, Horms wrote:
> > > On Thu, Jun 08, 2006 at 06:48:23AM +0800, Zou Nan hai wrote:
> > > > The ia64 kdump patch is in 2 parts.
> > > >
> > > > the kexec-kdump-ia64-2.6.16.patch should apply on top of the previo=
us
> > > > kexec patch by Khalid in Tony's test tree.
> > > >
> > > > the kexec-tools-kdump-ia64.patch should apply to kexec-tools-1.101
> > > > with kexec-tools-1.101-kdump.patch
> > > >
> > > >
> > > > To test it.
> > > > Build first SMP kernel with KEXEC and KDUMP enabled.
> > > >
> > > > Boot it with kernel parameter "crashkernel=3DXXX@YYY"
> > > > means reserver XXX from YYY for crashdumping.
> > > > Build an UP kernel with KEXEC KDUMP VMCORE enabled.
> > > > load this kernel as a crashdumping kernel
> > > > kexec -p vmlinux.gz --initrd=3Dinitrd --append=3D"...."
> > > >
> > > > trigger a crash,
> > > > maybe "echo c > /proc/sysrq-trigger"
> > > > after the crash kernel boots,
> > > > cp /proc/vmcore core
> > > >
> > > > gdb first_kernel_vmlinux core
> > > >
> > > > please test and review.
> > > >
> > > > Signed-off-by: Khalid Aziz <khalid_aziz@hp.com>
> > > > Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> > >
> > > Hi,
> > >
> > > I'm very excited to be able to play with the new version of this patc=
h,
> > > but the version you posted seems to included include all the kexec pa=
tch
> > > that went into Tony Luck's tree. Here is a rediff relative to the
> > > existing kexec patch (no other changes).
> > >
> > > The code does seem to be working for me. The main difficulty so far
> > > seems to have been finding an appropriate place and size and place for
> > > the reserved area. 128M@256M seems to work for me, offering enough
> > > memory and not lie on a resource boundry for me.
> > >
> > > Lastly, is it possible for you to comment on what areas of concern
> > > you have with regards to kdump/kexec on ia64. I am looking to port th=
is
> > > code to xen, as my colleague Magnus Damm and I have already done so f=
or
> i386
> > > (complete) and x86_64 (almost complete).
> > >
> > >
> http://lists.xensource.com/archives/html/xen-devel/2006-05/msg01272.html
> > >
> > > Signed-Off-By: Horms <horms@verge.net.au>
> > >
> >
> >  Thanks for testing and review.
> >
> >  There is still a lot of work to do for ia64 Kdump to be a very useful
> > and robust feature.
> >
> >  Major issues.
> >  1. Full percpu dumping on INIT.
> >     You may notices I only send an IPI to user CPUs and dump part of
> > registers for crashing CPU.Just stop other CPUs, not dumping their
> > status. This is only a temp hack.
> >  On other platforms they did this by an NMI, on IA64 we should use INIT
> > to acknowledge other CPUs. And I know on some platform there is a
> > trigger on panel can trigger INIT. We could use that to dump at the time
> > of deadlock. But currently INIT is used by MCA, we need to find a way to
> > coordinate with MAC on INIT.
> >
> >  2. unwind section is missing in vmcore.
> >     When you do a readelf on vmcore, you may notice there is no unwind
> > sections. We should add this percpu stack unwind sections to help dump
> > filter tools to analize the core dump.
> >
> >  3. kdump path at crash time.
> >     Currently I still have to do a irq->end on each level triggered irq,
> > without that the MPT fusion driver can not restart. We should fix this,
> > at least do that in a way of not touching any memory in previous kernel.
> >
> >  4. Other than this, we need port the dump filter to IA64.
> >
> > There are still some minor issues.
> > e.g
> >   When I get a crash when X is active, the new kernel will startup in a
> > blank screen(network is still working). I have indeed do a brute force
> > VGA reset on in purgatory code. But that seems to only shutdown the VGA
> > but not reinit it if X is running.
> >
> >   Current kexec can't not run on a kexec'd kernel, that is because the
> > memory region of EFI memmap is not reserverd in /proc/iomem, I will sent
> > a patch to reserve that region later.
> >
> > There should be other issues and gaps need to find out.
>=20
> Thanks for that list, it is very useful to me. I hope that I can
> find some time to help with some of those problems.
>=20
> One thing that I am puzzling over is why you shutdown the PCI devices
> as part of machine_crash_shutdown(). As I am trying to port your code
> to xen this is quite a problem for me, as I'm not sure that Xen
> actually knows enough about PCI to do this. Its it a problem relating
> to bringing the devices back online after a reboot? Is it the MPT fusion
> problem you mention above?
>=20
  The list is a bit wrong.., I notice that we don't need to dump unwind seg=
ment to core file for stack unwind to work... I am working on full register=
 dumping and fixing the stack unwind issue.

 The PCI device shutdown code was to un-master all the PCI devices so that =
no DMA transaction will be issued by Device. However I think maybe we can r=
emove this code because the new kernel memory space is invisible to first k=
ernel.

There is another problem that I call irq->end for each devices, it is not s=
afe to touch any pointer belong to previous kernel at the crash time.
But without this code, MPT fusion driver is very likely unable to restart. =
It sometimes failed to restart even with the irq->end code. This is an open=
 issue need to be fixed.

Thanks
Zou Nan hai

> Horms
> H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/e=
n/
