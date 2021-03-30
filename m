From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Tue, 30 Mar 2021 07:19:58 +0000
Subject: [PATCH v2 3/3] hpsa: add an assert to prevent from __packed reintroduction
Message-Id: <20210330071958.3788214-3-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com>
 <20210330071958.3788214-1-slyfox@gentoo.org>
In-Reply-To: <20210330071958.3788214-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin K. Petersen" <martin.petersen@oracle.com>, Arnd Bergmann <arnd@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don Brace <don.brace@microchip.com>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi <linux-scsi@vger.kernel.org>, jszczype@redhat.com, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, thenzl@redhat.com
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>

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
 drivers/scsi/hpsa_cmd.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/scsi/hpsa_cmd.h b/drivers/scsi/hpsa_cmd.h
index 885b1f1fb20a..ba6a3aa8d954 100644
--- a/drivers/scsi/hpsa_cmd.h
+++ b/drivers/scsi/hpsa_cmd.h
@@ -22,6 +22,9 @@
 
 #include <linux/compiler.h>
 
+#include <linux/build_bug.h> /* static_assert */
+#include <linux/stddef.h> /* offsetof */
+
 /* general boundary defintions */
 #define SENSEINFOBYTES          32 /* may vary between hbas */
 #define SG_ENTRIES_IN_CMD	32 /* Max SG entries excluding chain blocks */
@@ -454,6 +457,15 @@ struct CommandList {
 	atomic_t refcount; /* Must be last to avoid memset in hpsa_cmd_init() */
 } __aligned(COMMANDLIST_ALIGNMENT);
 
+/*
+ * Make sure our embedded atomic variable is aligned. Otherwise we break atomic
+ * operations on architectures that don't support unaligned atomics like IA64.
+ *
+ * The assert guards against reintroductin against unwanted __packed to
+ * the struct CommandList.
+ */
+static_assert(offsetof(struct CommandList, refcount) % __alignof__(atomic_t) = 0);
+
 /* Max S/G elements in I/O accelerator command */
 #define IOACCEL1_MAXSGENTRIES           24
 #define IOACCEL2_MAXSGENTRIES		28
-- 
2.31.1
