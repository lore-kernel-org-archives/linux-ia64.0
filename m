From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 19 Dec 2001 17:57:46 +0000
Subject: [Linux-ia64] #ifdef missing in linux/irq_cpustat.h
Message-Id: <marc-linux-ia64-105590698805712@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

as far as I understand the type irq_cpustat_t is not defined on IA64
therefore the line (in include/linux/irq_cpustat.h):

extern irq_cpustat_t irq_stat[];                        /* defined in asm/hardirq.h */

should probably be inside an    #ifndef CONFIG_IA64   block...

Best regards,
Erich



