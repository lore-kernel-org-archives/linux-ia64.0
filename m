From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 02 May 2005 12:50:30 +0000
Subject: [PATCH 6/6]: SN Hotplug Driver - PREEMPT/pcibus_info fix
Message-Id: <42762216.5010303@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090700010507070200070504"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090700010507070200070504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------090700010507070200070504
Content-Type: text/plain;
 name="pcibus_info.patch-6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcibus_info.patch-6"

This patch fixes an issue with the PROM and a kernel running with
CONFIG_PREEMPT enabled.  When CONFIG_PREEMPT is enabled, the size of a
spinlock_t changes -- resulting in the PROM writing to an incorrect location.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

 pcibr_provider.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -urNp hp/include/asm-ia64/sn/pcibr_provider.h final/include/asm-ia64/sn/pcibr_provider.h
--- hp/include/asm-ia64/sn/pcibr_provider.h	2027-04-28 13:30:25.000000000 -0400
+++ final/include/asm-ia64/sn/pcibr_provider.h	2027-04-28 13:31:08.000000000 -0400
@@ -108,10 +108,11 @@ struct pcibus_info {
 	char                    pbi_hub_xid;
 
 	uint64_t                pbi_devreg[8];
-	spinlock_t              pbi_lock;
 
 	uint32_t		pbi_valid_devices;
 	uint32_t		pbi_enabled_devices;
+
+	spinlock_t              pbi_lock;
 };
 
 /*

--------------090700010507070200070504--
