From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 02 Aug 2002 15:56:33 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905885@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The patch basically looks fine to me, except for some naming issues.
> We now have vectors, global vectors, global system interrupts (GSIs),
> irq numbers, and what not.  This is confusing and hard to maintain.
> We should settle on a consistent set of names (hopefully something
> consistent with Linux, ACPI spec, and PCI spec).  I tried to do this a
> while ago (see big comment at the beginning of iosapic.c), but the
> picture described there is incomplete for large machines and doesn't
> do a good job at integrating with ACPI lingo.  Anyone want to take a
> stab?

This has been bugging me for a long time, too.  If nobody beats
me to it, I'll post a proposal next week.  How do you want to
handle the merging -- we now have a couple patches that I did
earlier, Takayoshi's patch, and the proposed naming patch that
all touch iosapic.c?  If you send me your current iosapic.c, I
can work from that.
-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard Company

