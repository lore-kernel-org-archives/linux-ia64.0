From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:35:58 +0000
Subject: [PATCH] Fix unused variable cpe_poll_timer
Message-Id: <20050719013558.GG10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix

arch/ia64/kernel/mca.c:109: warning: 'cpe_poll_timer' defined but not used

when building for the simulator, which has no ACPI

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -106,7 +106,9 @@ static ia64_mc_info_t		ia64_mc_info;
 #define CPE_HISTORY_LENGTH    5
 #define CMC_HISTORY_LENGTH    5
 
+#ifdef CONFIG_ACPI
 static struct timer_list cpe_poll_timer;
+#endif
 static struct timer_list cmc_poll_timer;
 /*
  * This variable tells whether we are currently in polling mode.
