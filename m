From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Dec 2003 18:23:23 +0000
Subject: RE: hardware error state at cmc
Message-Id: <marc-linux-ia64-107090799908270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107090003329219@msgid-missing>
In-Reply-To: <marc-linux-ia64-107090003329219@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hello,
> could anyone give me a hint about the meaning of the following
> appearing in system.log (i2000, 2.6.0-test4, uptime ~40 days):
> 
> kernel: +BEGIN HARDWARE ERROR STATE AT CMC
> kernel: +Err Record ID: 37    SAL Rev:  0.02
> kernel: +Time: 12/03/2003 18:56:34    Severity 258
> kernel: +Processor Device Error Info Section
> kernel:  Processor Error Map: 0x4000
> kernel:  Processor State Param: 0x8000000fff611b0
> kernel:  Processor LID: 0x3000000
> kernel: + Cache check info[0]
> kernel: +  Level: L0, Index: 0, Operation: Unknown,
> kernel:  CPUID Regs: 0x49656e69756e6547 0x6c65746e 0x0 0x7000804
> kernel: +END HARDWARE ERROR STATE AT CMC

One of your processors had a correctible error in its cache. The
cpu fixed it, but interrupted the OS to tell you it that it happened.

The "Processor LID" field should tell you which cpu had the error
(should match the "cr.lid" value of one of you cpus).  This is
probably the 37th error since system reset (Error Record ID is
37).  You might want to check your logs to see what kinds of errors
were reported for the previous 36 errors to see if there is any sort
of pattern (which may indicate real hardware problems).  If the
errors are of different types, and reported by different processors,
then you may just be seeing stray neutrons flipping bits as they
pass through.

You might also want to get 2.6.0-test11 and apply Keith Owens patch
http://marc.theaimsgroup.com/?l=linux-ia64&m6974968032730&w=2 to
get easier to read logs, together with Keith's "salinfo" package,
which Bjorn hosted at:
ftp://ftp.kernel.org/pub/linux/kernel/people/helgaas/salinfo-0.4.tar.gz

-Tony Luck
