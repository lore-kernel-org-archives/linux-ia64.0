From: tony.luck@intel.com
Date: Wed, 27 Jul 2005 00:14:34 +0000
Subject: Re: [patch] properly stop devices before poweroff
Message-Id: <200507270014.j6R0EYMv005786@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F03FCF24C@scsmsx401.amr.corp.intel.com>
In-Reply-To: <20050726121019.0248801c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: kaneshige.kenji@jp.fujitsu.com, ambx1@neo.rr.com, greg@kroah.org, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Andrew Morton wrote:
> "Luck, Tony" <tony.luck@intel.com> wrote:
> >
> > I started on my OLS homework from Andrew ... and began looking
> > into what is going on here.
> > 
> 
> Thanks ;) I guess we'll end up with a better kernel, even though you appear
> to be an innocent victim here.

The "Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:851"
messages are caused by a missing call to free_irq() in the mpt/fusion driver.
I think that it should go here ... but someone with a clue should verify:

diff --git a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptbase.c
--- a/drivers/message/fusion/mptbase.c
+++ b/drivers/message/fusion/mptbase.c
@@ -1384,6 +1384,8 @@ mpt_suspend(struct pci_dev *pdev, pm_mes
 	/* Clear any lingering interrupt */
 	CHIPREG_WRITE32(&ioc->chip->IntStatus, 0);
 
+	free_irq(ioc->pci_irq, ioc);
+
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, device_state);
 

But even this doesn't fix the hang during shutdown :-(

The remaining problem is cause by the order of the calls in sys_reboot:

                device_suspend(PMSG_SUSPEND);
                device_shutdown();

The call to device_suspend() shuts down the mpt/fusion driver.  But then
device_shutdown() calls sd_shutdown() which prints:

  Synchronizing SCSI cache for disk sdb

and then calls sd_sync_cache().  Now since we suspended mpt/fusion, this is
going to go nowhere.

I don't know how to fix this.  Re-ordering the suspend & shutdown just looks
wrong.

-Tony
