From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 May 2003 16:57:32 +0000
Subject: Re: [Linux-ia64] sys_clone() related info/help/pointer needed
Message-Id: <marc-linux-ia64-105590723706044@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705986@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705986@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 May 2003 13:36:19 -0700 (PDT), Raj Patil <rpatil0296@yahoo.com> said:

  Raj> The progam basically adds an entry to syscall table, and when
  Raj> this new syscall is called, it simply calls sys_clone() with
  Raj> same arguments.  (like making a duplicate sys_clone call)
  Raj> static long my_call(unsigned long flags, unsigned long sz) {
  Raj> rc=sys_clone(flags, sz); /* sys_clone is exported */ ......  }
  Raj> Everything seems to work excpet that the child process created
  Raj> is not getting executed.

clone() (or, more correctly: clone2()) is special: it needs both a
pt_regs and a switch_stack structure at the top of the stack (see
comments in arch/ia64/kernel/process.c for copy_thread()).  Your
test-case doesn't work because it probably isn't creating the
switch_stack structure at all.

	--david

