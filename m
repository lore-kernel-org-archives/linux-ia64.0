From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 14 Mar 2012 21:12:06 +0000
Subject: Re: [PATCH] IA64: fix ISA IRQ trigger model and polarity setting
Message-Id: <CA+8MBbLsA8OysJNFMN4a0p6Yj3qmmawvtE0pGtcnAJpULjNi+A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1331647629-11550-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1331647629-11550-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <liuj97@gmail.com>
Cc: Liu Jiang <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, open list <linux-kernel@vger.kernel.org>, chenkeping@huawei.com

> When handling Interrupt Source Override in MADT table, the default
> ISA IRQ trigger model and poliarity should be edge-rising.
> Current IA64 implmentation doesn't follow the specification and
> set default ISA IRQ trigger model as level-low. With that wrong
> configuration and when system runs out of interrupt vectors,
> it will cause vector sharing among edge triggered ISA IRQ and
> level triggered PCI IRQ, then interrupt storm. So change the code
> to follow the specification.

I chased the reference in ACPI to the MPS spec:
 http://www.intel.com/design/pentium/datashts/24201606.pdf

Which says in table 4-10 "for example. EISA is active-low for
level triggered interrupt" and "for example, EISA is edge-triggered".

It looks to me that if MADT says "high", we should set high, if it says
"low" we should set low. Ditto for trigger vs. level. But if we see the
value "0" - then we have more work to do to determine what the
bus we are on uses for its default.

Did you find some other specification that gives a better explanation?
Or did I miss something - can we only get to this routine for ISA?

You've tested this patch - and it works for you - but is there a risk
that it will break someone else?

-Tony
