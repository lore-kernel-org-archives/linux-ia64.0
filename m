From: "Donny Cooper" <dcooper@atcc.necsys.com>
Date: Thu, 14 Mar 2002 22:40:13 +0000
Subject: [Linux-ia64] Kernel Shared Memory Max (shmmax)
Message-Id: <marc-linux-ia64-105590701905286@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does the maximum possible shared memory (shmmax) increase with the Enterprise kernel?

Below is from doc/sysctl/kernel.txt document.
Is this document valid for IA-64 kernel?

It seems you can set this value to pretty much anything (even larger than the available memory), so I'm assuming the
value gets intelligently truncated to the max supported.  How can I check how much shared mem is available, `free` or
`top` just shows what's used, right?

...doc/sysctl/kernel.txt
===============================

shmmax:

This value can be used to query and set the run time limit
on the maximum shared memory segment size that can be created.
Shared memory segments up to 1Gb are now supported in the
kernel.  This value defaults to SHMMAX.

===============================


Thanks,
-----------------------------------
Donny Cooper
NEC Systems, Inc.
Advanced Technical Computing Center
dcooper@atcc.necsys.com
-----------------------------------


