From: Erich Focht <focht@ess.nec.de>
Date: Mon, 21 May 2001 15:33:17 +0000
Subject: [Linux-ia64] exporting __cpu_physical_id
Message-Id: <marc-linux-ia64-105590693005633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

does anything speak against adding the line

EXPORT_SYMBOL(__cpu_physical_id);

somewhere into arch/ia64/kernel/smp.c ?
I'd need to use the hardware CPU IDs from within a loadable module and I
didn't find any other 'exported' function or array with the needed
information...

Thanks in advance!

Best regards,
Erich 

---
Erich Focht                                    <efocht@ess.nec.de>
NEC European Supercomputer Systems, European HPC Technology Center
Hessbruehlstr. 21B, 70565 Stuttgart, Germany
phone: +49-711-78055-15                    fax  : +49-711-78055-25



