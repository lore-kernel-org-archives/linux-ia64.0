From: "Ashok Raj" <ashok.raj@intel.com>
Date: Mon, 26 Apr 2004 16:16:44 +0000
Subject: RE: [RFC IA64 Hotplug] [Patch 1/7] core_kernel_init.patch
Message-Id: <ORSMSX404XRPmcarcR40000019b@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041LEdyt3cew00000172@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041LEdyt3cew00000172@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   

>-----Original Message-----
>From: Andrew Morton [mailto:akpm@osdl.org]
>Sent: Sunday, April 25, 2004 10:36 PM
>To: Raj, Ashok
>Cc: lhcs-devel@lists.sourceforge.net; linux-ia64@vger.kernel.org;
>davidm@hpl.hp.com; rusty@rustcorp.com.au; Luck, Tony; Mallick, Asit K;
>Saxena, Sunil; Shah, Rajesh
>Subject: Re: [RFC IA64 Hotplug] [Patch 1/7] core_kernel_init.patch
>
>
>These patches were disastrously wordwrapped by your mailer (usually an
>indication that the code is using too-long lines, too).
>
>Having nothing better to do, I fixed them all up and applied them to my
>tree, thanks.
>
>One of the patches adds a KDB initialisation hook to init/main.c.  Was this
>deliberate?

Nope. The kdb was inadvertently included by mistake.. sorry about that.

I forgot one step in using the LOOKOUT to get the word wrap thingy to fix..
I will be careful the next time :-(



Cheers,
ashok raj
- Linux Core Software Group


