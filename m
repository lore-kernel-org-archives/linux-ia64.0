From: glider@google.com
Date: Wed, 11 Mar 2020 12:11:24 +0000
Subject: [PATCH 2/2] ia64: add IRQENTRY_TEXT and SOFTIRQENTRY_TEXT to linker script
Message-Id: <20200311121124.243352-1-glider@google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, Alexander Potapenko <glider@google.com>, kbuild test robot <lkp@intel.com>

This is needed to fix linker errors caused by lib/stackdepot.c
referencing __{soft,}irqentry_text_{start,end}.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 arch/ia64/kernel/vmlinux.lds.S | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 1ec6b703c5b4f..6b5652ee76f96 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -54,6 +54,8 @@ SECTIONS {
 		CPUIDLE_TEXT
 		LOCK_TEXT
 		KPROBES_TEXT
+		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.gnu.linkonce.t*)
 	}
 
-- 
2.25.1.481.gfbce0eb801-goog
