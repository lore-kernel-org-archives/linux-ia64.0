From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 16 Mar 2005 19:34:29 +0000
Subject: Re: [PATCH/RFC]: Clean up of sn_irq_info list for PCI Hotplug
Message-Id: <200503161134.29905.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42276523.3060107@sgi.com>
In-Reply-To: <42276523.3060107@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, March 15, 2005 12:32 pm, Prarit Bhargava wrote:
> I propose the following change to the sn/kernel arch SN IRQ handling.
>
> The central issue here is that the current unidirectional list
> implementation in sn_irq_info does not easily allow sn_irq_info struct
> removals when PCI devices are hotplug removed from the system.
>
> After input from a few others I changed my approach in the patch.
> Please reconsider it for submission to the community.

Patch looks ok to me, Prarit, much better than what we had (i.e. it works 
during hotplug).  We can continue to cleanup this file later, after you get 
the hotplug driver accepted.

Jesse
