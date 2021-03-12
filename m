From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Fri, 12 Mar 2021 22:27:18 +0000
Subject: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <20210312222718.4117508-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
In-Reply-To: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Sergei Trofimovich <slyfox@gentoo.org>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi@vger.kernel.org, Joe Szczypek <jszczype@redhat.com>, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, Tomas Henzl <thenzl@redhat.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Don Brace <don.brace@microchip.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>

The failure initially observed as boot failure on rx3600 ia64 machine
with RAID bus controller: Hewlett-Packard Company Smart Array P600:

    kernel unaligned access to 0xe000000105dd8b95, ip=0xa000000100b87551
    kernel unaligned access to 0xe000000105dd8e95, ip=0xa000000100b87551
    hpsa 0000:14:01.0: Controller reports max supported commands of 0 Using 16 instead. Ensure that firmware is up to date.
    swapper/0[1]: error during unaligned kernel access

Here unaligned access comes from 'struct CommandList' that happens
to be packed. The change f749d8b7a ("scsi: hpsa: Correct dev cmds
outstanding for retried cmds") introduced unexpected padding and
un-aligned atomic_t from natural alignment to something else.

This change does not remove packing annotation from struct but only
restores alignment of atomic variable.

The change is tested on the same rx3600 machine.

CC: linux-ia64@vger.kernel.org
CC: storagedev@microchip.com
CC: linux-scsi@vger.kernel.org
CC: Joe Szczypek <jszczype@redhat.com>
CC: Scott Benesh <scott.benesh@microchip.com>
CC: Scott Teel <scott.teel@microchip.com>
CC: Tomas Henzl <thenzl@redhat.com>
CC: "Martin K. Petersen" <martin.petersen@oracle.com>
CC: Don Brace <don.brace@microchip.com>
Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Suggested-by: Don Brace <don.brace@microchip.com>
Fixes: f749d8b7a "scsi: hpsa: Correct dev cmds outstanding for retried cmds"
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 drivers/scsi/hpsa_cmd.h | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/hpsa_cmd.h b/drivers/scsi/hpsa_cmd.h
index d126bb877250..617bdae9a7de 100644
--- a/drivers/scsi/hpsa_cmd.h
+++ b/drivers/scsi/hpsa_cmd.h
@@ -20,6 +20,9 @@
 #ifndef HPSA_CMD_H
 #define HPSA_CMD_H
 
+#include <linux/build_bug.h> /* static_assert */
+#include <linux/stddef.h> /* offsetof */
+
 /* general boundary defintions */
 #define SENSEINFOBYTES          32 /* may vary between hbas */
 #define SG_ENTRIES_IN_CMD	32 /* Max SG entries excluding chain blocks */
@@ -448,11 +451,20 @@ struct CommandList {
 	 */
 	struct hpsa_scsi_dev_t *phys_disk;
 
-	bool retry_pending;
+	int retry_pending;
 	struct hpsa_scsi_dev_t *device;
 	atomic_t refcount; /* Must be last to avoid memset in hpsa_cmd_init() */
 } __aligned(COMMANDLIST_ALIGNMENT);
 
+/*
+ * Make sure our embedded atomic variable is aligned. Otherwise we break atomic
+ * operations on architectures that don't support unaligned atomics like IA64.
+ *
+ * Ideally this header should be cleaned up to only mark individual structs as
+ * packed.
+ */
+static_assert(offsetof(struct CommandList, refcount) % __alignof__(atomic_t) = 0);
+
 /* Max S/G elements in I/O accelerator command */
 #define IOACCEL1_MAXSGENTRIES           24
 #define IOACCEL2_MAXSGENTRIES		28
-- 
2.30.2
