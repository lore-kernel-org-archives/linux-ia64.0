From: "Ashok Raj" <ashok.raj@intel.com>
Date: Mon, 26 Apr 2004 04:47:25 +0000
Subject: RE: [RFC IA64 Hotplug] [Patch 7/7] migrate_irq.patch
Message-Id: <ORSMSX404EXUIEAOeIi00000198@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX404NsokLQ8aZR00000175@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX404NsokLQ8aZR00000175@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>-----Original Message-----
>From: Kenji Kaneshige [mailto:kaneshige.kenji@jp.fujitsu.com]
>Sent: Sunday, April 25, 2004 8:29 PM
>To: Raj, Ashok; LHCS list
>Cc: linux-ia64@vger.kernel.org; davidm@hpl.hp.com; akpm@osdl.org; Rusty
>Russell; Luck, Tony; Mallick, Asit K; Saxena, Sunil; Shah, Rajesh
>Subject: RE: [RFC IA64 Hotplug] [Patch 7/7] migrate_irq.patch
>
>Hi Ashok,
>
>I think some parts of your patch are required not only to support
>CPU removal, but also to fix the following problem of IRQ affinity of
>current ia64 linux :)
>
>Current irq_affinity_write_proc() changes unmasked RTEs by force.
>But I think it is dangerous because it might cause a race condition
>if some interrupts are generated while changing the RTE.
>
>Your patch solves this problem by changing the RTE while the
>interrupt is pending, doesn't it?

Thanks for looking in to the patch Kaneshige san. 

You are correct. This patch also has a portion required by general affinity
handler code. I was planning to do this separately, but got a little lazy
and put both together.. :-) 

Cheers,
Ashok Raj
[Linux core software team]

