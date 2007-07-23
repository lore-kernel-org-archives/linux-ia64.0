From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jul 2007 22:42:08 +0000
Subject: RE: Linus' tree broken?
Message-Id: <617E1C2C70743745A92448908E030B2A01FEC5EF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I am hitting this on my rx2620, rx6600 and rx2600 (i.e. everywhere I
> have tried it) and the bisection is showing that it appears to have been
> broken before -rc1.

Are you booting a generic kernel, or a zx1_defconfig based one?  Look
back in the linux-ia64 archives a few days for a post titled:

 "Regression in serial console on ia64 after 2.6.22"

Perhaps you are hitting this?

-Tony
