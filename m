From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:23:41 +0000
Subject: [PATCH] xen: compilation fix of drivers/xen/events.c on IA64
Message-Id: <20080826052341.GB1496%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-ia64@vger.kernel.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com

use set_xen_guest_handle() instead of direct assigning.

> linux-2.6/drivers/xen/events.c: In function 'xen_poll_irq':
> linux-2.6/drivers/xen/events.c:757: error: incompatible types in assignment
> make[4]: *** [drivers/xen/events.o] Error 1

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/xen/events.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/xen/events.c b/drivers/xen/events.c
index c3290bc..81e00ee 100644
--- a/drivers/xen/events.c
+++ b/drivers/xen/events.c
@@ -772,7 +772,7 @@ void xen_poll_irq(int irq)
 
 		poll.nr_ports = 1;
 		poll.timeout = 0;
-		poll.ports = &evtchn;
+		set_xen_guest_handle(poll.ports, &evtchn);
 
 		if (HYPERVISOR_sched_op(SCHEDOP_poll, &poll) != 0)
 			BUG();
-- 
1.6.0.rc0.42.g186458
