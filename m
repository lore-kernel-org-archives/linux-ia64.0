From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 03 May 2001 02:34:43 +0000
Subject: [Linux-ia64] NMI handling
Message-Id: <marc-linux-ia64-105590693005522@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm trying to add an NMI oopser to ia64 kdb to help debug disabled
spinloops.  I can add the NMI handler but AFAICT I am wasting my time.
local_irq_save and friends do rsm psr.i which will mask all interrupts,
including NMI (arch volume 2, table 5-7).

Can we use cr.tpr.mmi (arch volume 2, section 5.8.3.3) instead of
psr.i?  That will disable all external interrupts other than NMI.
cr.tpr.mmi still allows PMI interrupts, where psr.i does not, is that a
problem?


