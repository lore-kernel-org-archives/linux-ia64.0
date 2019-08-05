From: Chuhong Yuan <hslester96@gmail.com>
Date: Mon, 05 Aug 2019 07:26:59 +0000
Subject: [PATCH 1/2] ia64: hp-sim: Replace strncmp with str_has_prefix
Message-Id: <20190805072659.32745-1-hslester96@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Chuhong Yuan <hslester96@gmail.com>

strncmp(str, const, len) is error-prone since the len is
easy to be wrong because of counting error or sizeof(const)
without - 1.

Use the newly introduced str_has_prefix() to substitute
it to make code better.

Signed-off-by: Chuhong Yuan <hslester96@gmail.com>
---
 arch/ia64/hp/sim/boot/bootloader.c | 2 +-
 arch/ia64/hp/sim/simeth.c          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/hp/sim/boot/bootloader.c b/arch/ia64/hp/sim/boot/bootloader.c
index 6d804608dc81..bcb7af27466c 100644
--- a/arch/ia64/hp/sim/boot/bootloader.c
+++ b/arch/ia64/hp/sim/boot/bootloader.c
@@ -112,7 +112,7 @@ start_bootloader (void)
 	ssc((long) &stat, 0, 0, 0, SSC_WAIT_COMPLETION);
 
 	elf = (struct elfhdr *) mem;
-	if (elf->e_ident[0] = 0x7f && strncmp(elf->e_ident + 1, "ELF", 3) != 0) {
+	if (elf->e_ident[0] = 0x7f && !str_has_prefix(elf->e_ident + 1, "ELF", 3)) {
 		cons_write("not an ELF file\n");
 		return;
 	}
diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index f39ef2b4ed72..9ad812cd8d0e 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -248,7 +248,7 @@ simeth_open(struct net_device *dev)
 /* copied from lapbether.c */
 static __inline__ int dev_is_ethdev(struct net_device *dev)
 {
-       return ( dev->type = ARPHRD_ETHER && strncmp(dev->name, "dummy", 5));
+       return (dev->type = ARPHRD_ETHER && !str_has_prefix(dev->name, "dummy"));
 }
 
 
-- 
2.20.1
