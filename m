From: Keith Owens <kaos@sgi.com>
Date: Thu, 01 Sep 2005 03:20:46 +0000
Subject: Re: testing mca/init patch
Message-Id: <12725.1125544846@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
In-Reply-To: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005 16:43:15 -0700,=20
tony.luck@intel.com wrote:
>To make life easier for testers, I've applied Keith's patches
>and put them into my test tree.
>
>I locally applied one insignificant change in ia64_init_handler()
>to print the cpu number and the state of sos->monarch in the
>initial printk in that routine (because there was once a bug where
>Tiger SAL sent all cpus to the registered "master" INIT entry point.
>The output below shows that I have a good SAL that didn't do this).
>I haven't applied this change to my GIT tree.
>
>
>Here's a trimmed down version of the output after I hit the INIT
>button with some comments by me about timing inside {} brackets:
>
>{nothing for a few seconds ... felt like more than 5}

That delay is coming from your SAL, nothing I can do about it.

>CPU1: Entered OS INIT handler. PSP=FFe301a0 monarch=3D1
>Delaying for 5 seconds...
>{another delay, perhaps this one was 5 seconds}

Probably 10 seconds.  5 in ia64_init_handler(), then another 5 in
ia64_wait_for_slaves().  See below.

>Processes interrupted by INIT - 0 (cpu 1 task 0xe0000001ffe90000)

Only one cpu was entered for INIT, not good.

>INIT dump complete.  Monarch on cpu 1 returning to normal service.
>{another several second delay}

This is wrong.  The slave INIT handler was not invoked when the monarch
was delivered, instead the slave events were delivered _after_ the
monarch returned to the interrupted context.  It works for me on SGI's
SAL, all the cpus enter INIT at the same time, without any noticeable
delay.  There is no delay nor lockout in the INIT handler code before
it gets to the first printk, so all the delay and out of order
execution has to be coming from your SAL.

>CPU3: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
>{another several second delay}
>CPU2: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
>{another several second delay}
>CPU0: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
>{another several second delay}
>CPU1: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
>cpu 1, INIT inconsistent r12 and r13, original stack not modified

And why was cpu 1 entered again, this time as a slave and with wrong
registers?  Looks like another SAL error.

>{system hung}

Because all 4 cpus are driven as slaves.  All the slaves are waiting
for the monarch to arrive.  All of the above tells me that the OS code
is working fine, SAL is not.

