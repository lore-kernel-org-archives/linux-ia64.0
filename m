From: Grant Grundler <iod00d@hp.com>
Date: Wed, 03 Mar 2004 23:35:27 +0000
Subject: Re: [PATCH] more robust halt_light
Message-Id: <20040303233527.GP27501@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 03, 2004 at 02:08:00PM -0700, Alex Williamson wrote:
> 
>    I was curious about that myself, but I thought I remembered from
> Stephane that the perf counters didn't really recover from a
> PAL_HALT_LIGHT on McKinley.

The way I recall Stephane explaining it to me was the PMU
was completely disabled after returning from PAL_HALT_LIGHT.
ISTR no PAL fix was never released for Mckinley. And even if
one was, we'd have to convince HP firmware teams to roll
and qualify it. Unlikely.

> If that's not the case, maybe we can move
> the PAL check into perfmon code, and it can selectively disable it as it
> needs via the disable_hlt API.

I don't think that's likely...but poke stephane again when he's back.
But I do like rohit's idea that perfmon enable/disable PAL_HALT
when it starts/stops using the PMU.
grant

> I assume there are some cases were
> perfmon wouldn't need to disable halt_light on working PAL,
> so the rev check might not go away.
> 
> 	Alex
> 
> On Wed, 2004-03-03 at 13:38, Seth, Rohit wrote:
> > The issue with performance counters is only when PAL_HALT_LIGHT is
> > enabled.  It is nice to be able to use this power save feature when the
> > performance counters are not currently/actively used system wide.  Can
> > we use the disable_hlt and enable_hlt APIs (mentioned in the patch
> > below) in perfmon kind of tools to disable/enable PAL_HALT_LIGHT
> > whenever the system is transitioning in and out of system wide
> > performance monitoring.  That way we don't have to have any tests for
> > Mckinley, PAL versions etc. etc.
> > 
> > rohit
> > >-----Original Message-----
> > >Sent: Wednesday, March 03, 2004 9:57 AM
> > >To: linux-ia64@vger.kernel.org
> > >Subject: [PATCH] more robust halt_light
> > >
> > >
> > >  This patch adds some i386-ish enable/disable features to the
> > >pal_halt_light cpu idle implementation as well as tries to avoid bad
> > >interactions with certain revs of PAL on McKinley cpus.  Hopefully this
> > >will provide enough flexibility that we can leave it configured on in
> > >the kernel by default.  My latest measurements on a 1.3GHz rx2600 show
> > >that enabling pal_halt_light in the cpu_idle routine saves 23W/cpu on
> > an
> > >idle system.
> > >
> > >   FWIW, I added the enable/disable_hlt routines.  I don't see any
> > >consumers of this for ia64 now, but it looked useful.  Patch against
> > >latest linux-2.5 bk.  Thanks,
> > >
> > >	Alex
> > >
> 
> -- 
> Alex Williamson                             HP Linux & Open Source Lab
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
