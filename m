From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 19 Nov 2004 06:42:01 +0000
Subject: RE: [2.6 patch] IA64 irq.c: remove CONFIG_X86 code
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F026C5938@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041119001915.GL4943@stusta.de>
In-Reply-To: <20041119001915.GL4943@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>, davidm@hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>I don't see how this code could ever be used.
>
>Am I correct or did I miss something?
>
>
>diffstat output:
> arch/ia64/kernel/irq.c |   33 ---------------------------------
> 1 files changed, 33 deletions(-)

Thanks to a helpful hint from Christoph earlier this week I put
together a patch that throws away over 900 lines from the ia64
irq.c

http://marc.theaimsgroup.com/?l=linux-ia64&m0072859114157&w=2

It's queued up in an internal tree waiting for 2.6.11 to open.

Some parts of your patch may still be needed.

-Tony
