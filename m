From: "Yu, Luming" <luming.yu@intel.com>
Date: Fri, 12 Mar 2004 15:15:01 +0000
Subject: RE: cat /proc/acpi/events bad for your system's health!
Message-Id: <3ACA40606221794F80A5670F0AF15F8401CBB74D@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16455.50905.681007.50048@napali.hpl.hp.com>
In-Reply-To: <16455.50905.681007.50048@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
>   Luming> I confirm this issue here on tiger with 2.6.4-rc3 kernel ,
>   Luming> but 2.4 is ok.  Not sure this is a regression.
> 
> OK.  I assume you (or Len) will take care of it?
> 

The following patch make crash on my tiger gone.   However I didn't dig
out the true culprit.  Maybe this is due to excessive optimization. 

BTW, my gcc version is 3.2.3 .

Thanks,
Luming

diff -Bru 2.6-acpi/drivers/acpi/bus.c patched/drivers/acpi/bus.c
--- 2.6-acpi/drivers/acpi/bus.c	2004-02-27 09:17:52.000000000 +0800
+++ patched/drivers/acpi/bus.c	2004-03-12 23:03:05.000000000 +0800
@@ -335,6 +335,7 @@
 		remove_wait_queue(&acpi_bus_event_queue, &wait);
 		set_current_state(TASK_RUNNING);
 
+		acpi_os_stall(100);
 		if (signal_pending(current))
 			return_VALUE(-ERESTARTSYS);
 	}
