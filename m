From: Martin Pool <mbp@samba.org>
Date: Tue, 29 Jul 2003 08:28:04 +0000
Subject: MCA OS INIT from TOC button on rx6000?
Message-Id: <marc-linux-ia64-105946742524614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just ran up 2.5.72 on an hp rx6000 in the hope of testing MCA
handling.  Some of the documentation lead me to believe that pressing
the TOC button on the back of the machine ought to cause an MCA that
would print out the machine state.  But when I do that, the machine
just stops dead.

We built the kernel with 

CONFIG_IA64_MCA=y

and I defined IA64_MCA_DEBUG_INFO in asm-ia64/mca.h.  The machine is
using the VGA console.

At bootup it does seem to be successfully talking to PAL to set this
up

Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_init: begin
Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_init: registered mca rendezvous spinloop and wakeup mech.
Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_init: registered os mca handler with SAL at 0x404d620, gp = 0x488a930
Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_init: os init handler at 404e700
Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_init: registered os init handler with SAL
Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_platform_init: CPU 0 corrected machine check vector 0x1f setup and enabled.
Jul 30 03:13:44 caosc-zx6000 kernel: ia64_mca_platform_init: CPU 0 CMCV = 0x0000000000001f
...
Jul 30 03:13:46 caosc-zx6000 kernel: ia64_mca_cpe_int_handler: received interrupt. CPU:0 vector = 0x0

There are no messages when I press TOC; the machine just stops.  The
behaviour is the same under RH 7.1AS.

Could it be that this needs a serial console?

I'd appreciate any suggestions.

-- 
Martin 
