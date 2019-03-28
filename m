From: Robert Richter <rrichter@marvell.com>
Date: Thu, 28 Mar 2019 07:55:18 +0000
Subject: Re: [PATCH v2] efi: Unify dmi setup code over architectures arm/arm64, io64 and x86
Message-Id: <20190328075510.svjbjdonrncrr73m@rric.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190320130502.16667-1-rrichter@marvell.com>
 <20190320131607.vgst3r7ynha55ikw@rric.localdomain>
 <20190320152240.2eun63wqkbqmuqkg@rric.localdomain>
 <CAKv+Gu8ta4ZSKwcFGOaf7XCam29ZrHkNowDjfdCpfQas=Xo7Fg@mail.gmail.com>
In-Reply-To: <CAKv+Gu8ta4ZSKwcFGOaf7XCam29ZrHkNowDjfdCpfQas=Xo7Fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Jean Delvare <jdelvare@suse.com>, Marcin Benka <mbenka@marvell.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>

On 27.03.19 19:53:47, Ard Biesheuvel wrote:
> On Wed, 20 Mar 2019 at 16:23, Robert Richter <rrichter@marvell.com> wrote:
> >
> > On 20.03.19 14:16:07, Robert Richter wrote:
> > > On 20.03.19 13:05:37, Robert Richter wrote:
> > > > @@ -167,6 +167,7 @@ static int __init arm_dmi_init(void)
> > > >      * itself, depends on dmi_scan_machine() having been called already.
> > > >      */
> > > >     dmi_scan_machine();
> > > > +   dmi_memdev_walk();
> > > >     if (dmi_available)
> > > >             dmi_set_dump_stack_arch_desc();
> > > >     return 0;
> > >
> > > After
> > >
> > >  [PATCH] efi/arm: Show SMBIOS bank/device location in cper and
> > >   ghes error logs
> > >
> > > wents in for arm/arm64, we can unify the code. See patch below.
> >
> > V2 with the fix in arm_dmi_init() below.
> >
> 
> Could you please resend this as a proper patch? I am having trouble applying it.

I just resent the patch. But this worked for me:

 $ wget -nd -O - https://lore.kernel.org/patchwork/patch/1052718/mbox/ | git am -smc -3 -

Not sure what was wrong.

Thanks,

-Robert

