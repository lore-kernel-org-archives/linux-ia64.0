From: Tony Luck <tony.luck@intel.com>
Date: Thu, 16 May 2019 01:04:14 +0000
Subject: [PATCH: Linus please apply] ia64: Make sure that we have a mmiowb function real early
Message-Id: <20190516010414.30623-1-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Generic kernels feed many operation through the "machvec"
logic to get the correct form of the operation for the
current system. "mmiowb()" is one of those operations.

Although machvec is initialized very early in boot, it isn't
early enough for a recent upstream kernel change that added
mmiowb to the spin_unlock() path.

Statically initialize the mmiowb field of machvec so that we
won't die with a call through a NULL pointer. This should be
safe because we do the real initialization of machvec before
bringing up any addtional CPUs or doing any I/O.

Fixes: 49ca6462fc9e ("ia64/mmiowb: Add unconditional mmiowb() to arch_spin_unlock()")
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/kernel/machvec.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/machvec.c b/arch/ia64/kernel/machvec.c
index 1b604d02250b..ebd82535f51b 100644
--- a/arch/ia64/kernel/machvec.c
+++ b/arch/ia64/kernel/machvec.c
@@ -10,7 +10,9 @@
 
 #include <asm/page.h>
 
-struct ia64_machine_vector ia64_mv;
+struct ia64_machine_vector ia64_mv = {
+	.mmiowb	= ___ia64_mmiowb
+};
 EXPORT_SYMBOL(ia64_mv);
 
 static struct ia64_machine_vector * __init
-- 
2.20.1
