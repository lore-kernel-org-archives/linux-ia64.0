From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 03 Oct 2001 20:32:49 +0000
Subject: Re: [Linux-ia64] X4.1.0 reboots and log
Message-Id: <marc-linux-ia64-105590698805296@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805295@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 3 Oct 2001 11:26:44 -0700, Randolph Chung <randolph@tausq.org> said:

  Randolph> One thing I noticed is that the crashes seem to coincide
  Randolph> with certain messages in the event log. I've posted an
  Randolph> excerpt at http://gandalf.tausq.org/tmp/kern.log

  Randolph> Does this help anyone debug the problem? I was told that
  Randolph> this:

It's definitely a useful observation; thanks for pointing it out.

  Randolph> Oct 2 12:16:52 pippin kernel: +Platform PCI Component
  Randolph> Error Info Section Oct 2 12:16:52 pippin kernel: + PCI
  Randolph> Component Error Detail: Error Status: 0x1000 Oct 2
  Randolph> 12:16:52 pippin kernel: Component Info: Vendor Id   Randolph> 0x8086, Device Id = 0x84e0, Class Code = 0x0,
  Randolph> Seg/Bus/Dev/Func = 4/0/0/6

  Randolph> corresponds to a "address above top of memory" error
  Randolph> reported by the SAC, but don't know how to trace this down
  Randolph> more.

Based on tables B-2/B-4 in the SAL spec, I'd interpret an Error status
of "0x1000" as:

	ERR_BUS Error detected in the bus.

That's not very telling... ;-(

I looked through your log file, but couldn't find any useful
addresses.  Could someone more familiar with the MCA reports
tell me what this means:

	+ BUS Check Info [0]
	+ Status Info: 0 ,Severity: 0 ,Transaction Type: 1 ,Transaction Size: 7 ,Error: External

My suspicion is that the machine crashes either because something is
attempting to access a memory hole or because something is attempting
to perform an I/O device access via a cachable translation.  Perhaps
the above line would tell us which one it is, but I'm not sure what a
transaction type of "1" means.

	--david

