From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 08 Jun 2009 17:48:32 +0000
Subject: [PATCH] ia64: unexport fpswa.h
Message-Id: <20090608174832.GA29447@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1244118232.5172.26.camel@ht.satnam> <1244118476.5172.29.camel@ht.satnam> <1244118599.5172.31.camel@ht.satnam> <20090604202212.GD13892@uranus.ravnborg.org> <57C9024A16AD2D4C97DC78E552063EA3A89196D0@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3A89196D0@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

fpswa.h is not relevant for userspace,
so do not export it.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>
---
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index ccbe8ae..c7d0a71 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -2,7 +2,6 @@ include include/asm-generic/Kbuild.asm
 
 header-y += break.h
 header-y += fpu.h
-header-y += fpswa.h
 header-y += ia64regs.h
 header-y += intel_intrin.h
 header-y += perfmon_default_smpl.h
