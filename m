From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 19:56:47 +0000
Subject: [PATCH 4/6] IA64-setup: Use seq_putc() in show_cpuinfo()
Message-Id: <802ea8fd-b020-20f5-bcd2-9d58609e5c6b@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
In-Reply-To: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsO2cmcgUsO2ZGVs?= <jroedel@suse.de>, Krzysztof Kozlowski <krzk@kernel.org>, Robert Richter <rrichter@cavium.com>, Robin Murphy <robin.murphy@arm.com>, Tony Luck <tony.luck@intel.com>, Toshi Kani <toshi.kani@hpe.com>, Vineet Gupta <vgupta@synopsys.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 22 Oct 2016 20:42:20 +0200

A single character (line break) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/kernel/setup.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 7ec7acc..28741f7 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -705,8 +705,7 @@ show_cpuinfo (struct seq_file *m, void *v)
 			   "thread id  : %u\n",
 			   c->core_id, c->thread_id);
 #endif
-	seq_printf(m,"\n");
-
+	seq_putc(m, '\n');
 	return 0;
 }
 
-- 
2.10.1

