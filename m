From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 22 Feb 2002 18:45:51 +0000
Subject: Re: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905176@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Feb 2002 10:29:16 -0700, n0ano@indstorage.com said:

  Don> Jay- Check out the unaligned fault handler in
  Don> `arch/ia64/kernel/unaligned.c' That code should show you what
  Don> you need to do.

The code in unaligned.c is far more complicated than what Jay would
need.  It'll take a few minutes of staring at the instruction encoding
sections of the ia64 manual to figure out the most effective way for
doing this, but just narrowing an instruction down to something that
may do a store should be fairly easy (verify that the slot is an M
slot, look at the most signicant bits of the instruction, ...).  Don't
forget about the semaphore instructions though!

	--david

