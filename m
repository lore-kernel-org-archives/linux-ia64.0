From: "John Lee" <jlee@platsolns.com>
Date: Wed, 02 Jun 2004 20:34:11 +0000
Subject: MCA and processors in SAL_BOOT_RENDEZ status
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony and MCA experts, 

I have several questions w/r/t the global MCA escalation and APs left
waken-not when maxcpu is used to limit the number of processors for
Linux.
Per SAL spec, they are in BOOT_RENDEZV and hence not initialized/set to
handle the MC_RENDEZV_VECTOR that Linux MCA is to set. I.e., they are
active processors from SAL's view but nothing from Linux's.

Q1: Do they participate in SAL's monarch selection anyway and can
possibly be the monarch to execute OS_MCA code ? Or they just cannot
join the RENDEZVOUS and receive INIT later ?

Q2: the same question w/ the processors in HALT/HALT_LIGHT status.

Q3: the same question w/ the processors that are logically deconfigured
from Linux kernel at runtime but the deconfiguration has no report back
to SAL. In this case, SAL still sees the processor and can select it as
a monarch to execute OS_MCA which will conflict with Linux kernel.

Thanks,
John

