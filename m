From: Erich Focht <efocht@hpce.nec.com>
Date: Fri, 18 Jul 2003 16:15:44 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105854507724102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks good, applies cleanly on top of 2.6.0-test1 + ia64 but doesn't
boot on TX7 :-( Dies right after the elilo output lines... Maybe Tak
(CC'd) finds some time to have a look?

Regards,
Erich


On Friday 18 July 2003 02:16, Jesse Barnes wrote:
> On Thu, Jul 17, 2003 at 10:23:37AM +0200, Erich Focht wrote:
> > Maybe that should better be
> >      bool "Discontiguous memory support" if (IA64_DIG && NUMA)
> >
> > Discontigmem alone doesn't make sense, yet, I think...
>
> Not for ia64 I guess, unless we make zx1 use discontig as well.  Patch
> appended.
>
> Thanks,
> Jesse


