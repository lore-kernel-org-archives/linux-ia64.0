From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Dec 2006 23:35:22 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2AE35502@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Biggest part of this is the kexec/kdump changes (which include a teeny generic
> change to add an icache flush option to kernel/kexec.c).

There are a few more patches in the queue that I'll be piling together
for another pull ... but I wanted to get the kexec/kdump monster out
of the way (it needs a little more love and attention ... there are
build errors if you configure KEXEC=y, KDUMP=n ... I took a first stab
at just fixing arch/ia64/kernel/Makefile to move crash.o into a KDUMP
dependent line of its own, which helped some, but left me with a couple
of undefined symbols at link time.  Chasing them led into generic files :-(

Stuff I know I've not dealt with yet (but plan to)

kprobes: fix to allow probes on slot 1 + qp bits on special instructions
FP exception logging overhead
XPC deadlock
remove some rsm psr.dt in ivt.S

Less certain stuff ...

Ken's patch to not use a DTR for percpu area will need a little adjustment
to fit with kexec (I think).

SGIs patches for asymmetric systems (different cpu models) are still worrying
me about how far this stuff may go ... the first two patches look fine, but
I get the feeling that we'll be peeling more layers here.

Other stuff isn't technically lost, but is piled into corners of my
not-so-efficient patch tracking system ... gentle reminders appreciated.

-Tony
