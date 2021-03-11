From: Bhaskar Chowdhury <unixbhaskar@gmail.com>
Date: Thu, 11 Mar 2021 06:22:58 +0000
Subject: [PATCH] ia64: kernel: Few typos fixed in the file fsys.S
Message-Id: <20210311061058.29492-1-unixbhaskar@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <e26a1461-0d05-d79c-7688-de45d285e068@infradead.org>
In-Reply-To: <e26a1461-0d05-d79c-7688-de45d285e068@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: unixbhaskar@gmail.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: rdunlap@infradead.org


Mundane spelling fixes.

Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
---
 arch/ia64/kernel/fsys.S | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 0750a716adc7..2094f3249019 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -172,7 +172,7 @@ ENTRY(fsys_gettimeofday)
 	// r25 = itc_lastcycle value
 	// r26 = address clocksource cycle_last
 	// r27 = (not used)
-	// r28 = sequence number at the beginning of critcal section
+	// r28 = sequence number at the beginning of critical section
 	// r29 = address of itc_jitter
 	// r30 = time processing flags / memory address
 	// r31 = pointer to result
@@ -432,7 +432,7 @@ GLOBAL_ENTRY(fsys_bubble_down)
 	 *	- r29: psr
 	 *
 	 * We used to clear some PSR bits here but that requires slow
-	 * serialization.  Fortuntely, that isn't really necessary.
+	 * serialization.  Fortunately, that isn't really necessary.
 	 * The rationale is as follows: we used to clear bits
 	 * ~PSR_PRESERVED_BITS in PSR.L.  Since
 	 * PSR_PRESERVED_BITS=PSR.{UP,MFL,MFH,PK,DT,PP,SP,RT,IC}, we
--
2.26.2
