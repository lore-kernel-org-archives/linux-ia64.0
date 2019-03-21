From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 21 Mar 2019 10:14:16 +0000
Subject: Re: [PATCH v2] efi: Unify dmi setup code over architectures arm/arm64, io64 and x86
Message-Id: <CAKv+Gu9RbNUc0hqQ=8hzF=taEu03ywB1gVFswObKKDH2DP+sNw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190320130502.16667-1-rrichter@marvell.com> <20190320131607.vgst3r7ynha55ikw@rric.localdomain>
 <20190320152240.2eun63wqkbqmuqkg@rric.localdomain> <CAKv+Gu8HKUQPr7TaUm7EwdVFasUitAPBJFotpG43nNAKMBvxdA@mail.gmail.com>
 <20190321093920.beng2d3tbfvydbud@rric.localdomain> <CAKv+Gu899a5FpMqOzF5EVgsHRk37_PBxW8kVicgc8ST3=R_VUA@mail.gmail.com>
 <1553163110.5084.11.camel@suse.de>
In-Reply-To: <1553163110.5084.11.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean Delvare <jdelvare@suse.de>
Cc: Robert Richter <rrichter@marvell.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Marcin Benka <mbenka@marvell.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>

On Thu, 21 Mar 2019 at 11:11, Jean Delvare <jdelvare@suse.de> wrote:
>
> On Thu, 2019-03-21 at 10:51 +0100, Ard Biesheuvel wrote:
> > On Thu, 21 Mar 2019 at 10:39, Robert Richter <rrichter@marvell.com> wrote:
> > >
> > > On 20.03.19 23:02:09, Ard Biesheuvel wrote:
> > > > On Wed, 20 Mar 2019 at 16:23, Robert Richter <rrichter@marvell.com> wrote:
> > > > >
> > > > > On 20.03.19 14:16:07, Robert Richter wrote:
> > > > > > On 20.03.19 13:05:37, Robert Richter wrote:
> > > > > > > @@ -167,6 +167,7 @@ static int __init arm_dmi_init(void)
> > > > > > >      * itself, depends on dmi_scan_machine() having been called already.
> > > > > > >      */
> > > > > > >     dmi_scan_machine();
> > > > > > > +   dmi_memdev_walk();
> > > > > > >     if (dmi_available)
> > > > > > >             dmi_set_dump_stack_arch_desc();
> > > > > > >     return 0;
> > > > > >
> > > > > > After
> > > > > >
> > > > > >  [PATCH] efi/arm: Show SMBIOS bank/device location in cper and
> > > > > >   ghes error logs
> > > > > >
> > > > > > wents in for arm/arm64, we can unify the code. See patch below.
> > > > >
> > > > > V2 with the fix in arm_dmi_init() below.
> > > > >
> > > > > -Robert
> > > > >
> > > > >
> > > > > -- >8 --
> > > > > From: Robert Richter <rrichter@marvell.com>
> > > > > Subject: [PATCH v2] efi: Unify dmi setup code over architectures arm/arm64,
> > > > >  io64 and x86
> > > > >
> > > > > All architectures (arm/arm64, io64 and x86) do the same here, so unify
> > > > > the code.
> > > > >
> > > > > Note: We do not need to call dump_stack_set_arch_desc() in case of
> > > > > !dmi_available. Both strings, dmi_ids_string and dump_stack_arch_
> > > > > desc_str are initialized zero and thus nothing would change.
> > > > >
> > > >
> > > > I don't understand the last sentence - we do not need to call
> > > > dump_stack_set_arch_desc() when !dmi_available, but we do so anyway,
> > > > right? Doesn't that wipe the arch description we set based on the DT
> > > > machine name?
> > >
> > > No, in dmi_setup() we exit early when !dmi_available. So for arm/arm64
> > > nothing changed. But for x86 and ia64 we no longer call dump_stack_
> > > set_arch_desc() in this case. This is ok since both strings,
> > > dmi_ids_string and dump_stack_arch_desc_str, are initialized zero and
> > > copying one to the other does not change anything.
> > >
> >
> > Ah, of course. Apologies for not reading more carefully.
> >
> > I'll take this patch via the EFI tree.
>
> I like the idea. If this is not going through my tree then:
>
> Reviewed-by: Jean Delvare <jdelvare@suse.de>
>

Thanks Jean.
