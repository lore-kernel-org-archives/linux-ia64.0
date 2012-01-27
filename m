From: Yinghai Lu <yinghai@kernel.org>
Date: Fri, 27 Jan 2012 07:25:51 +0000
Subject: [PATCH 5/7] ia64, irq: add dummy create_irq_nr()
Message-Id: <1327649153-16477-6-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1327649153-16477-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1327649153-16477-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

create_irq() will return -1 when fail to allocate.
create_irq_nr() will return 0 when fail to allocate.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/irq_ia64.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 782c3a35..07fcbdc 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -431,6 +431,16 @@ int create_irq(void)
 	return irq;
 }
 
+unsigned int create_irq_nr(unsigned int from, int node)
+{
+	int irq = create_irq();
+
+	if (irq < 0)
+		irq = 0;
+
+	return irq;
+}
+
 void destroy_irq(unsigned int irq)
 {
 	dynamic_irq_cleanup(irq);
-- 
1.7.7

