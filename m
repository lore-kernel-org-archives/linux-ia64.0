From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Feb 2006 18:39:23 +0000
Subject: RE: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05C7C712@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What firmware version do you have on your zx2000?  I saw the same
>problem with my zx2000 running firmware 2.21 and was hacking at a work
>around, when I realized version 2.31 is available on the HP website.
>After upgrading, I don't see the hang any more.  Bjorn mentioned that he
>hasn't been able to reproduce the problem on his zx2000, probably
>because he has the latest firmware.  Please check and let us know.

Alex,

Thanks.  I was on f/w 2.21.  Upgrading to 2.31 fixes it, the latest
kernel now boots just fine.

-Tony
