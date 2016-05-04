From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Wed, 04 May 2016 11:17:49 +0000
Subject: [PATCH 4/5] ia64/traps: Silence GCC warning about uninitialised variable
Message-Id: <1462360670-27993-5-git-send-email-matt@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
In-Reply-To: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>

  arch/ia64/kernel/traps.c: In function 'ia64_fault':
  arch/ia64/kernel/traps.c:433:17: warning: 'siginfo.si_code' may be used uninitialized in this function [-Wmaybe-uninitialized]
    struct siginfo siginfo;

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>
Signed-off-by: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/ia64/kernel/traps.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index 6f7d4a4dcf24..77edd68c5161 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -548,6 +548,7 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 			return;
 		}
 		switch (vector) {
+		      default:
 		      case 29:
 			siginfo.si_code = TRAP_HWBKPT;
 #ifdef CONFIG_ITANIUM
-- 
2.7.3

