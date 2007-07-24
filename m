From: Doug Chapman <doug.chapman@hp.com>
Date: Tue, 24 Jul 2007 02:06:32 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185242792.5604.4.camel@phobos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-07-23 at 21:07 -0400, Doug Chapman wrote:
> On Mon, 2007-07-23 at 13:42 -0700, Luck, Tony wrote:
> > > > Could be, but it sounds like there's something fishy in the current
> > > > tree - Doug Chapman is having problems as well, presumably on zx1 boxes.
> > >
> > > I am seeing the panic on HP zx1 and zx2 systems.  Currently doing a git
> > > bisect to narrow it down.
> > 
> > 2.6.23-rc1 booted OK on my rx2620.  On the zx2000 too (though X is currently
> > behaving weirdly, I think that might be some other issue though).
> > 
> > -Tony
> 
> Through the magic of git-bisect I have narrowed it down to this commit
> (although I don't know why):
> 
> commit 4994be1b3fe9120c88022ff5c0c33f6312b17adb
> Author: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Date:   Tue Jul 17 21:22:33 2007 +0900
> 
>     [IA64] Add support for vector domain
>     
>     Add fundamental support for multiple vector domain. There still exists
>     only one vector domain even with this patch. IRQ migration across
>     domain is not supported yet by this patch.
>     
>     Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
>     Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> 

I have confirmed that it was my .config.  The panic is seen if the
kernel is compiled with CONFIG_IA64_GENERIC.  When I compiled with 
CONFIG_IA64_HP_ZX1 it worked OK.

- Doug


