From: Greg KH <greg@kroah.com>
Date: Tue, 29 Aug 2006 01:31:37 +0000
Subject: Re: [stable] [PATCH] Linux 2.6.17.11 - fix compilation error on IA64 (try #3)
Message-Id: <20060829013137.GA27869@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A72869D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A72869D@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Fernando Vazquez <fernando@oss.ntt.co.jp>, gregkh@suse.de, akpm@osdl.org, dev@openvz.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davem@davemloft.net, stable@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, xemul@openvz.org

On Mon, Aug 28, 2006 at 03:11:31PM -0700, Luck, Tony wrote:
> > The commit 8833ebaa3f4325820fe3338ccf6fae04f6669254 introduced a change that broke 
> > IA64 compilation as shown below:
> 
> What happened to the mainline version of the patch to which this
> is a fix (local DoS with corrupted ELFs)?  I don't see it in 2.6.18-rc5.
> Did it get fixed some other way, or is it just queued somewhere?  Or do
> we have a fix in -stable that isn't in mainline?

I thought this was a fix for a prior -stable patch that did not affect
mainline.  Or was this thought wrong?

thanks,

greg k-h
