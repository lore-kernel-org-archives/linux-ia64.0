From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 21 Apr 2004 01:15:14 +0000
Subject: RE: [PATCH][RFC] Vector sharing
Message-Id: <MDEEKOKJPMPMKGHIFAMAGEBMDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Thank you for your comments.

> An other or complementary way is to attach a vector only for interrupt
> lines witch are used, PCI slots have 4 interrupt lines but only 1 or
> sometime 2 are used by adapters.

I agree with attaching a vector only for interrupt lines which are used.
Your patch stops the waste of the vector resource, and it becomes difficult
for the lack of vectors to happen. I think we can also do this by using
Bjorn's
ACPI IRQ cleanup patch. To tell the truth, I also had a same idea before.

However, this idea doesn't solve the problem completely. The problem will
happen in the following case:

	o many PCI adapters have 2 or more functions
	o machine has more than 184 PCI slots in the same domain

So, I think vector sharing is necessary to solve this problem.

Thanks,
Kenji Kaneshige


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of
> Jean-Francois Neyroud
> Sent: Tuesday, April 20, 2004 9:25 PM
> To: Kenji Kaneshige
> Cc: linux-ia64@vger.kernel.org
> Subject: Re: [PATCH][RFC] Vector sharing
>
>
>
>
> Kenji Kaneshige wrote:
>
> >Hi,
> >
> >I'm trying to make a patch that allows device vectors to be shared by
> >multiple interrupt sources. This patch enables ia64 linux to boot on
> >the machine that has single vector number space and many device
> >interrupt sources (more than 184).
> >
> >I
> >
> Hi Kenji,
>
> An other or complementary way is to attach a vector only for interrupt
> lines witch are used, PCI slots have 4 interrupt lines but only 1 or
> sometime 2 are used by adapters.
>
> Find hereafter a patch tested on IA64 platform.
>
> Jean-Francois.
>
> --
> Jean-Francois Neyroud
> Bull SA
http://www-frec.bull.com



