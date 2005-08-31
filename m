From: tony.luck@intel.com
Date: Wed, 31 Aug 2005 23:43:15 +0000
Subject: testing mca/init patch
Message-Id: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

To make life easier for testers, I've applied Keith's patches
and put them into my test tree.

I locally applied one insignificant change in ia64_init_handler()
to print the cpu number and the state of sos->monarch in the
initial printk in that routine (because there was once a bug where
Tiger SAL sent all cpus to the registered "master" INIT entry point.
The output below shows that I have a good SAL that didn't do this).
I haven't applied this change to my GIT tree.


Here's a trimmed down version of the output after I hit the INIT
button with some comments by me about timing inside {} brackets:

{nothing for a few seconds ... felt like more than 5}
CPU1: Entered OS INIT handler. PSP=FFe301a0 monarch=3D1
Delaying for 5 seconds...
{another delay, perhaps this one was 5 seconds}
Processes interrupted by INIT - 0 (cpu 1 task 0xe0000001ffe90000)


Backtrace of pid 1 (init)

Call Trace:
 [<a000000100704ed0>] schedule+0xb90/0x14e0
                                sp=E0000001fef77d80 bsp=E0000001fef710e0
 [<a000000100706f40>] schedule_timeout+0xe0/0x1e0
                                sp=E0000001fef77d90 bsp=E0000001fef710a8
 [<a000000100166710>] do_select+0x330/0x7e0
                                sp=E0000001fef77dd0 bsp=E0000001fef70f78
 [<a000000100167130>] sys_select+0x570/0x9a0
                                sp=E0000001fef77df0 bsp=E0000001fef70e98
 [<a00000010000bd20>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000001fef77e30 bsp=E0000001fef70e98
 [<a000000000010640>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000001fef78000 bsp=E0000001fef70e98

{snipped dumps of lots of processes, all looked plausible}

Backtrace of pid 4684 (bash)

Call Trace:
 [<a000000100704ed0>] schedule+0xb90/0x14e0
                                sp=E00000018659fd60 bsp=E000000186599118
 [<a000000100707010>] schedule_timeout+0x1b0/0x1e0
                                sp=E00000018659fd70 bsp=E0000001865990e0
 [<a00000010043e9a0>] read_chan+0x5c0/0x13c0
                                sp=E00000018659fdb0 bsp=E000000186598fc0
 [<a000000100430460>] tty_read+0x1c0/0x1e0
                                sp=E00000018659fe20 bsp=E000000186598f78
 [<a000000100135a20>] vfs_read+0x180/0x380
                                sp=E00000018659fe20 bsp=E000000186598f20
 [<a000000100136250>] sys_read+0x70/0xe0
                                sp=E00000018659fe20 bsp=E000000186598ea8
 [<a00000010000bd20>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000018659fe30 bsp=E000000186598ea8
 [<a000000000010640>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000001865a0000 bsp=E000000186598ea8

INIT dump complete.  Monarch on cpu 1 returning to normal service.
{another several second delay}
CPU3: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
{another several second delay}
CPU2: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
{another several second delay}
CPU0: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
{another several second delay}
CPU1: Entered OS INIT handler. PSP=FFe301a0 monarch=3D0
cpu 1, INIT inconsistent r12 and r13, original stack not modified
{system hung}

The above is at least as good as the previous behaivour, but something
bad happened there at the end.  There were also more delays than I
was expecting.

-Tony
