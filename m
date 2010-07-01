From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 01 Jul 2010 15:22:02 +0000
Subject: [git pull] ia64 changes
Message-Id: <4c2cb29a36221fb56@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

Regression dates back to 2.6.32 - but I think this fits into the
"serious" bug category for late inclusion.

Thanks!

-Tony

 arch/ia64/mm/tlb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Tony Luck (1):
      [IA64] Fix spinaphore down_spin()

commit b70f4e85bfc4d7000036355b714a92d5c574f1be
Author: Tony Luck <tony.luck@intel.com>
Date:   Wed Jun 30 10:46:16 2010 -0700

    [IA64] Fix spinaphore down_spin()
    
    Typo in down_spin() meant it only read the low 32 bits of the
    "serve" value, instead of the full 64 bits. This results in the
    system hanging when the values in ticket/serve get larger than
    32-bits. A big enough system running the right test can hit this
    in a just a few hours.
    
    Broken since 883a3acf5b0d4782ac35981227a0d094e8b44850
        [IA64] Re-implement spinaphores using ticket lock concepts
    
    Reported via IRC by Bjorn Helgaas
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 5dfd916..7b3cdc6 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -121,7 +121,7 @@ static inline void down_spin(struct spinaphore *ss)
 	ia64_invala();
 
 	for (;;) {
-		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(serve) : "r"(&ss->serve) : "memory");
+		asm volatile ("ld8.c.nc %0=[%1]" : "=r"(serve) : "r"(&ss->serve) : "memory");
 		if (time_before(t, serve))
 			return;
 		cpu_relax();
