From: Will Deacon <will.deacon@arm.com>
Date: Thu, 12 May 2016 08:56:16 +0000
Subject: Re: [PATCH v6 00/14] ACPI NUMA support for ARM64
Message-Id: <20160512085616.GA25355@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
 <CAJZ5v0iMDQ4pWip4vyCos0o+1DFDvXQf4XZQqC4SGjJsDO4Lnw@mail.gmail.com>
 <20160511104032.GA31374@arm.com>
 <CAJZ5v0gQMR7OUyZo5Sa3bgMYZBzdnwFaktz9JCv1ocWXw7yHTg@mail.gmail.com>
 <57339F39.3040603@caviumnetworks.com>
 <CAJZ5v0h8zBEZ2nLLdk62r7uqHizUfVWamUVEriBGe1XBE6462Q@mail.gmail.com>
 <5733A47B.8030908@caviumnetworks.com>
 <CAJZ5v0gBTANFntBSkyaRtt-BKOMC+pz_R9CwM6wKnp=Ni1dPFA@mail.gmail.com>
In-Reply-To: <CAJZ5v0gBTANFntBSkyaRtt-BKOMC+pz_R9CwM6wKnp=Ni1dPFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: David Daney <ddaney@caviumnetworks.com>, David Daney <ddaney.cavm@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vg>

On Thu, May 12, 2016 at 12:29:02AM +0200, Rafael J. Wysocki wrote:
> On Wed, May 11, 2016 at 11:30 PM, David Daney <ddaney@caviumnetworks.com> wrote:
> > On 05/11/2016 02:22 PM, Rafael J. Wysocki wrote:
> >> On Wed, May 11, 2016 at 11:08 PM, David Daney <ddaney@caviumnetworks.com>
> >> wrote:
> >>> On 05/11/2016 01:35 PM, Rafael J. Wysocki wrote:
> >>>> On Wed, May 11, 2016 at 12:40 PM, Will Deacon <will.deacon@arm.com>
> >>>> wrote:
> >>>>> On Wed, May 11, 2016 at 02:43:11AM +0200, Rafael J. Wysocki wrote:
> >>>>> There's also a dependency on the arm64 for-next/core branch, so I've
> >>>>> been
> >>>>> largely ignoring this as far as 4.6 is concerned and was planning to
> >>>>> take
> >>>>> a proper look for 4.7 once the upcoming merge window is out of the way.
> >>>>
> >>>>
> >>>>
> >>>> That would be 4.7 and 4.8 respectively I suppose?

Argh, yes, of course! :)

> >>>>
> >>>> Anyway, Catalin has ACKed all of them except for the [13/14], so
> >>>> technically I can apply [1-12/14] now and then [13-14/14] can be
> >>>> applied when they are ready.
> >>>>
> >>>> Do you think there will be any problems with merging [6-7/14] into 4.7
> >>>> via the ACPI tree?
> >>>>
> >>>
> >>> I would defer to the arm64 maintainers for decisions about the arm64
> >>> specific parts of the patch set.  That said, many of the arm64 specific
> >>> patches depend on the arm64 for-next/core branch, so you would have to be
> >>> careful about merge ordering if you pull these in before the
> >>> for-next/core
> >>> branch is merged.
> >>
> >>
> >> Fair enough.  I will wait for an update then.
> >>
> >>> Also FWIW, I plan on addressing Catalin's comments about 13/14 and
> >>> posting a
> >>> new version of the patch set in the next day or two.
> >>
> >>
> >> OK, but in that case it won't be considered for 4.7 (at least not by
> >> me), so I'd suggest sending it in the second half of the 4.7 merge
> >> window (or about that time).
> >
> >
> > To be candid, I would very much like for you to pull in as many of the
> > patches as you are comfortable with as soon as possible.
> >
> > I don't know where Will and Catalin stand on this, and their opinion is
> > obviously important, but getting 1-12/14 merged to v4.7 and deferring the
> > last two for v4.8 would simplify the whole process for me.  The drawback is
> > carrying dead code around until the final parts are merged.
> 
> That is not unheard of, however.
> 
> OK, I'll try to put the [1-12/14] into my linux-next branch early next
> week and we'll see if that triggers any conflicts.

I'd really much rather this waited until after the merge window. My
understanding is that it's bad practice to put stuff into -next during the
merge window, and you'd end up having to send a pull based on a random
commit (the arm64 pull request?) in the second half. On top of that, this
series would get very little exposure in -next during that time.

On the other hand, putting this into linux-next after the merge window
gives us time for testing, allows David to rework patch 13 (which is aiming
for 4.8 anyway iiuc) and avoids merge window churn.

Will
