From: Matt_Domsch@Dell.com
Date: Wed, 06 Sep 2000 01:50:40 +0000
Subject: RE: [Linux-ia64] [PATCH] fix casting problem in megaraid driver
Message-Id: <marc-linux-ia64-105590678205455@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> we find that, yuck, this is another driver that hasn't been updated
> for the PCI DMA interface.  Not much point in hacking around in this
> driver until this gets rectified...
> 
> Note that the virt_to_bus() and bus_to_virt() macros have been
> obsoleted by the PCI DMA interface and will be removed from the kernel
> at some future point (I'm tempted to do this now so we'll discover
> right away which drivers need cleaning up).
> 
> Can you ask the megaraid maintainers to update their driver to use the
> PCI DMA interface?
> 
> 	--david

The update is in progress at AMI already.

Thanks,
Matt


