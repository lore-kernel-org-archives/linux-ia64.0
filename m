From: Erich Focht <focht@ess.nec.de>
Date: Tue, 15 Jan 2002 18:59:26 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > > is this with 1 CPU?
> >
> > no, it's with 2 CPUs. Does it make sense to try without CONFIG_SMP?
> 
> yes, UP scheduling is much simpler.

When booting with maxcpus=1 it died after:
...
Bringing up interface eth0:  [  OK  ]

With nosmp it died after
...
Enabling swap space:  [  OK  ]


I recompiled with CONFIG_SMP unset (needed only to put one line into
#ifdefs) and this (UP) version works. So there isn't anything
fundamentally wrong. I'll try running with CONFIG_DEBUG_SPINLOCK and
CONFIG_IA64_DEBUG_IRQ...

Regards,
Erich




