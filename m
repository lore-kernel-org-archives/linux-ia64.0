From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Dec 2003 23:33:54 +0000
Subject: Re: q-tools OOPS
Message-Id: <marc-linux-ia64-107092647632665@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092374429612@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092374429612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Dec 2003 09:46:18 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi David,
  Peter> Dunno what's going on here.  I've built q-tools against libpfm3.0
  Peter> and libc 2.3.2.ds1-10.0.1 from Debian using gcc 3.2.3.

Sounds fine.

  Peter> When run on a vanilla 2.6.0-test11 kernel, I either get no output, or
  Peter> an OOPS.  stracing q-syscollect always shows a SEGV in the child
  Peter> processes, but I think that may be an strace bug.
  Peter> I guess that this *could* be a preemption problem; have you run
  Peter> q-syscollect on a machine with CONFIG_PREEMPT on?

Nope, I definitely haven't tried CONFIG_PREEMPT.  It's obviously a
kernel bug, since q-syscollect doesn't do anything nasty---it's a pure
user-level program.  Can you try without CONFIG_PREEMPT?

	--david
