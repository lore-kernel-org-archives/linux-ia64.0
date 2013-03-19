From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 19 Mar 2013 09:36:13 +0000
Subject: [PATCH][RESEND] [IA64] tiocx: check retval from bus_register()
Message-Id: <alpine.LNX.2.00.1303191035010.9529@pobox.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>

Properly check return value from bus_register() and propagate it out of 
tiocx_init() in case of failure.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 arch/ia64/sn/kernel/tiocx.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index 14c1711..e35f648 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -490,11 +490,14 @@ static int __init tiocx_init(void)
 {
 	cnodeid_t cnodeid;
 	int found_tiocx_device = 0;
+	int err;
 
 	if (!ia64_platform_is("sn2"))
 		return 0;
 
-	bus_register(&tiocx_bus_type);
+	err = bus_register(&tiocx_bus_type);
+	if (err)
+		return err;
 
 	for (cnodeid = 0; cnodeid < num_cnodes; cnodeid++) {
 		nasid_t nasid;

-- 
Jiri Kosina
SUSE Labs
