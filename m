From: "Hall, Jenna S" <jenna.s.hall@intel.com>
Date: Tue, 11 Jun 2002 16:05:32 +0000
Subject: RE: [Linux-ia64] Does MCA handler work correctly?
Message-Id: <marc-linux-ia64-105590701905665@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905664@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905664@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Good observation - you are absolutely correct that the current
implementation is not SMP-safe.  The MCA handler is not functional yet -
currently, if you do get an MCA the OS handler will return to SAL with a
request to reboot the machine, and no attempt is made to recover.  (The
logging of hardware-corrected errors is functional, however.)

There is an effort in progress to code the OS recovery for selected MCAs.
This effort is part of the Atlas project:

http://atlas-64.sourceforge.net


Thanks,
Jenna

 -----Original Message-----
From: 	j-nomura@ce.jp.nec.com [mailto:j-nomura@ce.jp.nec.com] 
Sent:	Tuesday, June 11, 2002 5:01 AM
To:	linux-ia64@linuxia64.org
Subject:	[Linux-ia64] Does MCA handler work correctly?

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

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

