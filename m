From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Aug 2006 22:11:31 +0000
Subject: RE: [PATCH] Linux 2.6.17.11 - fix compilation error on IA64 (try #3)
Message-Id: <617E1C2C70743745A92448908E030B2A72869D@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156493587.2977.20.camel@localhost.localdomain>
In-Reply-To: <1156493587.2977.20.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fernando Vazquez <fernando@oss.ntt.co.jp>, gregkh@suse.de
Cc: dev@openvz.org, xemul@openvz.org, davem@davemloft.net, linux-kernel@vger.kernel.org, stable@kernel.org, akpm@osdl.org, linux-ia64@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com

> The commit 8833ebaa3f4325820fe3338ccf6fae04f6669254 introduced a change that broke 
> IA64 compilation as shown below:

What happened to the mainline version of the patch to which this
is a fix (local DoS with corrupted ELFs)?  I don't see it in 2.6.18-rc5.
Did it get fixed some other way, or is it just queued somewhere?  Or do
we have a fix in -stable that isn't in mainline?

-Tony
