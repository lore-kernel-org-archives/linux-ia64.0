From: j-nomura@ce.jp.nec.com
Date: Tue, 11 Jun 2002 12:01:04 +0000
Subject: [Linux-ia64] Does MCA handler work correctly?
Message-Id: <marc-linux-ia64-105590701905664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

does MCA handler of 2.4.18 work correctly on multiple processors?

While looking into mca.c and mca_asm.S, they have single static stack
area for MCA handling, but I could not find synchronization code
between processors.

It seems that when MCA occurs on multiple processors, they may break
stacks each other.

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

