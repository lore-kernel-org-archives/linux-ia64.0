From: wency@cn.fujitsu.com
Date: Wed, 05 Sep 2012 09:25:41 +0000
Subject: [RFC v9 PATCH 07/21] memory-hotplug: call acpi_bus_remove() to remove memory device
Message-Id: <1346837155-534-8-git-send-email-wency@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

The memory device has been ejected and powoffed, so we can call
acpi_bus_remove() to remove the memory device from acpi bus.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 9d47458..b152767 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -425,8 +425,9 @@ static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
 		}
 
 		/*
-		 * TBD: Invoke acpi_bus_remove to cleanup data structures
+		 * Invoke acpi_bus_remove() to remove memory device
 		 */
+		acpi_bus_remove(device, 1);
 
 		/* _EJ0 succeeded; _OST is not necessary */
 		return;
-- 
1.7.1

