From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Wed, 23 Jun 2004 14:26:40 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD8046AD43A@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/23/2004 6:38AM, Sharma Arun wrote:
>I saw it on a 4 way Tiger as well. The kernel was compiled using the
RHEL3
>toolchain.
>Saw the machine sitting in dispatch_to_fault_handler: with the IIP
pointing to
>count_reserved_pages(). I think IFA was 0.
>
>Didn't get a chance to debug this further.
>
>	-Arun

I also saw such hang on Tiger, when rpmbuild on SLES9-RC2. I'm
suspecting that recent patch which moves init_task to region 5 may break
sth there.

Env:
Tiger 4 with 4 Madison
SLES9-RC2 (linux-2.6.5-7.79)

Description:
Before rpmbuild, I applied partial-page patch derived from David's tree,
which happened to contain another patch to move init_task to region 5.
Then when I booted the new kernel created by rpmbuild (so by default
config file), Tiger hangs immediately. 

Excluding patch for moving init_task made problem away.
======Kernel just stopped at general_exception(), with IIP pointing to
count_reserved_pages():
IIP: 0xa0000001000594a0 (In count_reserved_pages)
ISR: 0x00000028400000030
IFA: 0xe00000004fefe6018

Then by single step:
General_exception() -> dispatch_to_default_handler() ->
SAVE_MIN_WITH_COVER_R19:
	MINSTATE_GET_CURRENT(r16);	//r16 = 0xa00000010070c000
(&init_task)
	...
	adds r16=IA64_TASK_THREAD_ON_USTACK_OFFSET,r16;
\
	;;
\
	ld1 r17=[r16];	<------Just in this point, ITP also hangs and
seems another fault happening. 

I'm suspecting line in ia64_switch_to:
	/*
	* If we've already mapped this task's page, we can skip doing it
again.
	*/
(p6)	cmp.eq p7,p6=r27,r27 <----- Should here cmp.eq.unc be used
instead? No time to test it now...

Thanks,
Kevin
