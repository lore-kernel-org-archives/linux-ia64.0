From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Date: Tue, 07 Dec 2004 15:22:28 +0000
Subject: Re: [PATCH] IRQ resource deallocation[0/2]
Message-Id: <Pine.LNX.4.61.0412070820240.13396@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41B559DD.7040307@jp.fujitsu.com>
In-Reply-To: <41B559DD.7040307-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

On Tue, 7 Dec 2004, Kenji Kaneshige wrote:

> I had posted the IRQ resource deallocation patch a couple of monthes
> ago and I had incorporated all feedbacks from the mailing list
> (http://marc.theaimsgroup.com/?l=linux-kernel&m9688530703122&w=2).
> But it doesn't seems to be included yet, so I would like to try again.
> I hope my patch is included onto -mm tree since I want the patches
> be tested by many people.

You should remove the config option and make it unconditional.

Thanks,
	Zwane

