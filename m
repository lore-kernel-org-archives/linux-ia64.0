From: Baoquan He <bhe@redhat.com>
Date: Mon, 05 May 2014 06:57:39 +0000
Subject: Re: [Patch v3 1/2] introduce variable acpi_lapic into ia64
Message-Id: <20140505065739.GB1702@dhcp-16-105.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399265306-8553-1-git-send-email-bhe@redhat.com>
 <20140505051455.GA1702@dhcp-16-105.nay.redhat.com>
In-Reply-To: <20140505051455.GA1702@dhcp-16-105.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: rjw@rjwysocki.net, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, dyoung@redhat.com

On 05/05/14 at 01:14pm, Baoquan He wrote:
> Hi Rafael,
>=20
> Thanks for previous comments and suggestions.
>=20
>=20
> I added the acpi_lapic in ia64. However I didn't find ia64 machine to
> test it. Could you or anyone please help test this 2 patches?
>=20
> I don't know how to test UP system running SMP kernel with no LAPIC in
> MADT when it's ia64 arch.=20
>=20
> Test steps for ia64 kdump:
>=20
> 1) get a multi-cpus ia64 machine, build a upstream kernel with SMP and
> ACPI
> 2)install kexec-tools, and edit /etc/sysconfig/kdump to make sure
> "nr_cpus=3D1" is in KDUMP_COMMANDLINE_APPEND. Then load the kdump kernel
> by below command:
>=20
> "kdumpctl restart" or "systemctl restart kdump"

Sorry, here I assume people use fedora distros. The kdump execution
command is like below string which is taken from my fedora automation
script.

/sbin/kexec -p
'--command-line=3DBOOT_IMAGE=3D/vmlinuz-3.13.5-202.fc20.x86_64
root=3DUUID=F170152e-de83-46ee-9546-8ccd53f9753b ro rd.md=3D0 rd.lvm=3D0
rd.dm=3D0 vconsole.keymap=3Dus rd.luks=3D0 vconsole.font=3Dlatarcyrheb-sun16
console=3Dtty0 rd.shell LANG=3Den_US.UTF-8 console=3DttyS0,115200n8
intel_iommu=3Don irqpoll nr_cpus=3D1 reset_devices cgroup_disable=3Dmemory
mce=3Doff numa=3Doff udev.children-max=3D2 panic=10 rootflags=3Dnofail
disable_cpu_apicid=3D0'
--initrd=3D/boot/initramfs-3.13.5-202.fc20.x86_64kdump.img
/boot/vmlinuz-3.13.5-202.fc20.x86_64

Thanks
Baoquan

>=20
> 3) After kdump kernel loaded, execute below shell command. This can make
> crash happen in 2nd cpu.
>=20
> taskset -c 1 sh -c "echo c >/proc/sysrq-trigger"
>=20
>=20
> 4) From console, below error message should not be printed any more. And
> the cpu related to 2nd lapid is present, this can be checked by console
> message and adding debugging code.
>=20
> "acpi LNXCPU:0a: BIOS reported wrong ACPI id 0 for the processor."
>=20
> --------
> For x86_64, the UP test is taken by adding "disableapic nr_cpus=3D1" into
> cmdline of grub. The test for kdump is the same as above ia64.
>=20
> Thanks
> Baoquan
>=20
>=20
> On 05/05/14 at 12:48pm, Baoquan He wrote:
> > This variable was defined and assigned in x86, is used to indicate
> > whether LAPIC exists in MADT. Now introduce it into ia64 to help
> > make correct judgment when get information for acpi processor later.
> >=20
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> > ---
> >  arch/ia64/include/asm/acpi.h | 1 +
> >  arch/ia64/kernel/acpi.c      | 3 +++
> >  2 files changed, 4 insertions(+)
> >=20
> > diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
> > index d651102..b478219 100644
> > --- a/arch/ia64/include/asm/acpi.h
> > +++ b/arch/ia64/include/asm/acpi.h
> > @@ -85,6 +85,7 @@ ia64_acpi_release_global_lock (unsigned int *lock)
> >  	((Acq) =3D ia64_acpi_release_global_lock(&facs->global_lock))
> > =20
> >  #ifdef	CONFIG_ACPI
> > +extern int acpi_lapic;
> >  #define acpi_disabled 0	/* ACPI always enabled on IA64 */
> >  #define acpi_noirq 0	/* ACPI always enabled on IA64 */
> >  #define acpi_pci_disabled 0 /* ACPI PCI always enabled on IA64 */
> > diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> > index 0d407b3..615ef81 100644
> > --- a/arch/ia64/kernel/acpi.c
> > +++ b/arch/ia64/kernel/acpi.c
> > @@ -56,6 +56,7 @@
> > =20
> >  #define PREFIX			"ACPI: "
> > =20
> > +int acpi_lapic;
> >  unsigned int acpi_cpei_override;
> >  unsigned int acpi_cpei_phys_cpuid;
> > =20
> > @@ -676,6 +677,8 @@ int __init early_acpi_boot_init(void)
> >  	if (ret < 1)
> >  		printk(KERN_ERR PREFIX
> >  		       "Error parsing MADT - no LAPIC entries\n");
> > +	else
> > +		acpi_lapic =3D 1;
> > =20
> >  #ifdef CONFIG_SMP
> >  	if (available_cpus =3D 0) {
> > --=20
> > 1.8.5.3
> >=20
