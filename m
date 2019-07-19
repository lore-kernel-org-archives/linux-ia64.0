From: Michael Ellerman <mpe@ellerman.id.au>
Date: Fri, 19 Jul 2019 11:13:16 +0000
Subject: Re: [PATCH 1/2] arch: mark syscall number 435 reserved for clone3
Message-Id: <871rym8egj.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190714192205.27190-1-christian@brauner.io> <20190714192205.27190-2-christian@brauner.io> <e14eb2f9-43cb-0b9d-dec4-b7e7dcd62091@de.ibm.com> <20190716130631.tohj4ub54md25dys@brauner.io> <874l3i8h0l.fsf@concordia.ellerman.id.au> <20190719102503.tm3ahvkh4rwykmws@brauner.io>
In-Reply-To: <20190719102503.tm3ahvkh4rwykmws@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian@brauner.io>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Christian Brauner <christian@brauner.io> writes:
> On Fri, Jul 19, 2019 at 08:18:02PM +1000, Michael Ellerman wrote:
>> Christian Brauner <christian@brauner.io> writes:
>> > On Mon, Jul 15, 2019 at 03:56:04PM +0200, Christian Borntraeger wrote:
>> >> I think Vasily already has a clone3 patch for s390x with 435. 
>> >
>> > A quick follow-up on this. Helge and Michael have asked whether there
>> > are any tests for clone3. Yes, there will be and I try to have them
>> > ready by the end of the this or next week for review. In the meantime I
>> > hope the following minimalistic test program that just verifies very
>> > very basic functionality (It's not pretty.) will help you test:
>> 
>> Hi Christian,
>> 
>> Thanks for the test.
>> 
>> This actually oopses on powerpc, it hits the BUG_ON in CHECK_FULL_REGS
>> in process.c around line 1633:
>> 
>> 	} else {
>> 		/* user thread */
>> 		struct pt_regs *regs = current_pt_regs();
>> 		CHECK_FULL_REGS(regs);
>> 		*childregs = *regs;
>> 		if (usp)
>> 
>> 
>> So I'll have to dig into how we fix that before we wire up clone3.
>> 
>> Turns out testing is good! :)
>
> Indeed. I have a test-suite for clone3 in mind and I hope to have it
> ready by the end of next week. It's just always the finding the time
> part that is annoying. :)

I know the feeling!

> Thanks for digging into this, Michael!

No worries, happy to help where I can.

In the intervening five minutes I remembered how we handle this, we just
need a little wrapper to save the non-volatile regs:

_GLOBAL(ppc_clone3)
	bl	save_nvgprs
	bl	sys_clone3
	b	.Lsyscall_exit


A while back I meant to make it generate those automatically based on a
flag in the syscall.tbl but of course haven't got around to it :)

So with the above it seems all good:

$ ./clone3 ; echo $?
Parent process received child's pid 4204 as return value
Parent process received child's pidfd 3
Parent process received child's pid 4204 as return argument
Child process with pid 4204
0

I'll send a patch to wire it up on Monday.

cheers
