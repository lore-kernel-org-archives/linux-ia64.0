From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 05 Oct 2000 16:29:45 +0000
Subject: Re: [Linux-ia64] perfmon usage?
Message-Id: <marc-linux-ia64-105590678205543@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205542@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205542@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich,

> 
> I've looked at the perfmon.c in the arch/ia64/kernel directory of the
> kernel source. Not beeing a kernel expert I suspect that this is or will
> be a syscall called 'perfmonctl'.
> 
> Is there any tool available to play around with the performance counters
> by using this syscall?
> 
> Thanks in advance for the help,

There used to be a tool part of the PCL library which was originally 
ported by IBM along with the perfmon.c code. perfmon.c was later
enhanced slightly by NEC.

However this code is broken. The user tool does not count correctly.

I am in the process of fixing and enhancing the kernel code to support 
the entire feature set of the IA-64 PMU and in particular the Itanium
implementation. This code is not ready for prime time yet. 

Most likely there will be a sample tool to exercise the kernel code.

Stay tuned for more....

--Stephane


