From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Nov 2006 17:12:34 +0000
Subject: RE: [PATCH] ia64 enable trap code on slot 1
Message-Id: <617E1C2C70743745A92448908E030B2ACBEE71@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45592018.3040203@intel.com>
In-Reply-To: <45592018.3040203@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-#define __IA64_BREAK_KPROBE		0x80200
-#define __IA64_BREAK_JPROBE		0x80300
+#define __IA64_BREAK_KPROBE		0x81000
+#define __IA64_BREAK_JPROBE		0x82000

I think a comment here in break.h would be useful ... noting that
for JPROBE and KPROBE the low 12-bits are ignored.

Otherwise this looks like a neat solution to a tricky problem.

-Tony
