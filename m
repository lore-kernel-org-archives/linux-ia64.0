From: Jonathan Cameron <Jonathan.Cameron@Huawei.com>
Date: Tue, 14 Mar 2023 11:02:50 +0000
Subject: Re: [RFC PATCH 00/32] ACPI/arm64: add support for virtual cpuhotplug
Message-Id: <20230314110250.00005685@Huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
	<20230307120050.000032f1@Huawei.com>
	<1f21673e-e5e6-a158-94a4-6ae6724c1f93@arm.com>
In-Reply-To: <1f21673e-e5e6-a158-94a4-6ae6724c1f93@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: James Morse <james.morse@arm.com>
Cc: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K
 Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, kangkang.shen@futurewei.com

On Mon, 13 Mar 2023 15:50:52 +0000
James Morse <james.morse@arm.com> wrote:

> Hi Jonathan,
>=20
> On 07/03/2023 12:00, Jonathan Cameron wrote:
> > On Fri,  3 Feb 2023 13:50:11 +0000
> > James Morse <james.morse@arm.com> wrote: =20
>=20
> >> On a system that supports cpuhotplug the MADT has to describe every po=
ssible
> >> CPU at boot. Under KVM, the vGIC needs to know about every possible vC=
PU before
> >> the guest is started.
> >> With these constraints, virtual-cpuhotplug is really just a hypervisor=
/firmware
> >> policy about which CPUs can be brought online.
> >>
> >> This series adds support for virtual-cpuhotplug as exactly that: firmw=
are
> >> policy. This may even work on a physical machine too; for a guest the =
part of
> >> firmware is played by the VMM. (typically Qemu).
> >>
> >> PSCI support is modified to return 'DENIED' if the CPU can't be brought
> >> online/enabled yet. The CPU object's _STA method's enabled bit is used=
 to
> >> indicate firmware's current disposition. If the CPU has its enabled bi=
t clear,
> >> it will not be registered with sysfs, and attempts to bring it online =
will
> >> fail. The notifications that _STA has changed its value then work in t=
he same
> >> way as physical hotplug, and firmware can cause the CPU to be register=
ed some
> >> time later, allowing it to be brought online. =20
>=20
> > As we discussed on an LOD call a while back, I think that we need some =
path to
> > find out if the guest supports vCPU HP or not so that info can be queri=
ed by
> > an orchestrator / libvirt etc.  In general the entity responsible for a=
llocating
> > extra vCPUs may not know what support the VM has for this feature. =20
>=20
> I agree. For arm64 this is going to be important if/when there are machin=
es that do
> physical hotplug of CPUs too.
>=20
>=20
> > There are various ways we could get this information into the VMM.
> > My immediate thought is to use one of the ACPI interfaces that lets us =
write
> > AML that can set an emulated register. A query to the VMM can check if =
this
> > register is set.
> >=20
> > So options.
> >=20
> > _OSI() - Deprecated on ARM64 so lets not use that ;) =20
>=20
> News to me, I've only just discovered it!
>=20
>=20
> > _OSC() - Could add a bit to Table 6.13 Platform-Wide Capabilites in ACP=
I 6.5 spec.
> >          Given x86 has a similar online capable bit perhaps this is the=
 best option
> >          though it is the one that requires a formal code first proposa=
l to ASWG. =20
>=20
> I've had a go at writing this one:
> https://gitlab.arm.com/linux-arm/linux-jm/-/commit/220b0d8b0261d7467c8705=
e6f614d57325798859

From a quick glance that looks good to me.

>=20
> It'll appear in the v1 of the series once the kernel and qemu bits are al=
l lined up again.

We'll also need to kick off the spec change with a code-first proposal.
I think current standard way to do that is a bugzilla entry in EDK2 repo=20
https://bugzilla.tianocore.org/buglist.cgi?component=3DSpecification%20Upda=
te&product=EDK2%20Code%20First&resolution=3D---
and the get someone in ASWG to create equivalent tracking issue in mantis.

Great if you already have that in hand via relevant ARM folks.

Jonathan

>=20
>=20
> Thanks,
>=20
> James
>=20
>=20
> > _OSC() - Could add a new UUID and put it under a suitable device - mayb=
e all CPUs?
> >          You could definitely argue this feature is an operating system=
 property.
> > _DSM() - Similar to OSC but always under a device.
> >          Whilst can be used for this I'm not sure it really matches int=
ended usecase.
> >=20
> > Assuming everyone agrees this bit of introspection is useful,
> > Rafael / other ACPI specialists: Any suggestions on how best to do this=
? =20
>=20
