From: Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de>
Date: Mon, 08 Dec 2003 16:05:37 +0000
Subject: hardware error state at cmc
Message-Id: <marc-linux-ia64-107090003329219@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Hello,
could anyone give me a hint about the meaning of the following
appearing in system.log (i2000, 2.6.0-test4, uptime ~40 days):

kernel: +BEGIN HARDWARE ERROR STATE AT CMC
kernel: +Err Record ID: 37    SAL Rev:  0.02
kernel: +Time: 12/03/2003 18:56:34    Severity 258
kernel: +Processor Device Error Info Section
kernel:  Processor Error Map: 0x4000
kernel:  Processor State Param: 0x8000000fff611b0
kernel:  Processor LID: 0x3000000
kernel: + Cache check info[0]
kernel: +  Level: L0, Index: 0, Operation: Unknown,
kernel:  CPUID Regs: 0x49656e69756e6547 0x6c65746e 0x0 0x7000804
kernel: +END HARDWARE ERROR STATE AT CMC

  thanks
    christian

