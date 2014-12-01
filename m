From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Mon, 01 Dec 2014 22:42:52 +0000
Subject: Re: [PATCH] PM / Kconfig: Do not select PM directly from Kconfig files
Message-Id: <1709855.vJRHLWCgos@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <4088467.A4Xd3YfMSv@vostro.rjw.lan> <CAMuHMdU-PH=L4L-Jt8BVCvcFwJJY6PhEEBPWtO3wLhh2ndyA6g@mail.gmail.com>
In-Reply-To: <CAMuHMdU-PH=L4L-Jt8BVCvcFwJJY6PhEEBPWtO3wLhh2ndyA6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Linux-sh list <linux-sh@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Kevin Hilman <khilman@kernel.org>

On Monday, December 01, 2014 10:21:54 AM Geert Uytterhoeven wrote:
> On Sat, Nov 29, 2014 at 2:03 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> >
> > It is not valid to select CONFIG_PM directly without selecting
> > CONFIG_PM_SLEEP or CONFIG_PM_RUNTIME too, because that breaks
> > dependencies (ia64 does that) and it is not necessary to select
> > CONFIG_PM directly if CONFIG_PM_SLEEP or CONFIG_PM_RUNTIME is
> > set, because it will be set automatically then (sh does that).
> >
> > Fix those mistakes.
> >
> > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > ---
> >  arch/ia64/Kconfig |    1 -
> >  arch/sh/Kconfig   |    1 -
> 
> For the sh part:
> 
> Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Thanks!

> Note that sh is orphaned, so you should resend your patch to Andrew Morton,
> or queue it yourself.

Since it depends on material already in my tree, I'm going to queue it up myself.

Rafael

