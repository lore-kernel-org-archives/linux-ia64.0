From: Matt_Domsch@Dell.com
Date: Wed, 15 Mar 2000 15:54:54 +0000
Subject: [Linux-ia64] INIT switch handler
Message-Id: <marc-linux-ia64-105590678204984@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The init handler in arch/ia64/kernel/mca.c doesn't do anything yet.  Does
anyone have plans for what such a handler should or will do on Linux?

When the init switch is pressed, it causes a reset of the processor(s). The
purpose of the init
switch on Lion is the same as the NMI switch on the IA-32 platforms. The
OS will have to write a handler that will check and see that the init
switch has been pressed and dump the state of the processor and the state
of the system.
 
Thanks,
Matt Domsch
IA-64 Linux Lead Engineer
Dell Computer Corporation



