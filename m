From: =?iso-2022-jp?B?GyRCMyQzMDlASj8bKEJcKEthaWdhaSBLb2hlaVwp?=
Date: Wed, 09 Jun 2004 04:36:53 +0000
Subject: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_013C_01C44E26.D34ED820"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org, selinux@tycho.nsa.gov

This is a multi-part message in MIME format.

------=_NextPart_000_013C_01C44E26.D34ED820
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

Hello, everyone.

I observed kernel panic of linux-2.6.6 for IA-64, with SELinux.
(CONFIG_SECURITY=y and CONFIG_SECURITY_SELINUX=y)
I did a research about the problem, and found that there is an issue
with regard to the init_task initialization of IA-64.
I attached temporary workaround for the issue, but we should
come up with better solution.

[Overview]

While booing up the kernel with LSM/SELinux, init process tries to
execve() and one of the SELinux function is called to access init_task
(the parent of the init process)
Actually the LSM function tries to wake up tasks which is linked from
init_task, normally we expect nothing happens because init_task does
not have any linked tasks.
But because some members of init_task are initialized by wrong value,
due to the fact that IA-64 kernel image is now virtually mapped
from both region 5 and 7, it will lead to kernel panic.

I think this problem always happens when LSM/SELinux is enabled and
is IA-64 specific initialization issue.

[Detail]

The task_struct of cpu_idle (which is the parent of init process)
is named init_task and is defined in arch/ia64/kernel/init_task.c.
Init_task is initialized statically by INIT_TASK() macro at compile time.
The structure contains a wait_queue_head_t and a list_head in it.
Because the task_struct is linked to region 5 (0xa0....), the list_head
is also initialized to have region 5 addresses.

               |                       |
0xa0000000...  +=======================+
(region 5)     |                       |
               +-----------------------+
               |init_task              |
               |pid=0                  |
               |wait_chldexit.task_list|
               | +-------------------+ |
               | |next: 0xa000....   | |<--+ Initialized as empty list
               | +-------------------+ |   |  by referencing itself.
               | |prev: 0xa000....   | |<--+
               | +-------------------+ |
               |                       |
               +-----------------------+
               |                       |
              ===                     ===
               |                       |
0xe0000000...  +=======================+
(region 7)     |                       |
               +-----------------------+  <------ current of idle process
               |init_task              |
               |pid=0                  |
               |wait_chldexit.task_list|
               | +-------------------+ |
               | |next: 0xa000....   | |<--+ This list head is NOT EMPTY
               | +-------------------+ |   |  when accessed from region 7
               | |prev: 0xa000....   | |<--+
               | +-------------------+ |
               |                       |   <---+    +-----------------+
               +-----------------------+       |    | init process    |
               |                       |       |    | pid=1           |
               |                       |       +----- parent=init_task|
                                                    +-----------------+

As the current (r13) for the init_task is initialized in head.S to point
region 7 address (0xe0...), its child (init) will have region 7 address
for its parent address.

When the init process(PID=1) call execve(), LSM/SELinux hook function 
tries to access the wait_chldexit waiting queue of the cpu_idle.
Since this doubly linked list is broken by above reason,
kernel panic occurred.  Oops!

This problem came up to the surface for the first time by enabling SELinux.
Is it right referring to the parent of init?


[Solution]

Please find the attached patch to fix the problem.
The patch re-initializes current->wait_chldexit waitqueue, using
correct region 7 address in the head of setup_arch().

This solution is simple but sounds a bit ad hoc and I am seeking
better solution. I tried other 2 ways to fix the problem below,
but both of them failed.

1) I tried to move the init_task to region 7, by modifying linker
   script arch/ia64/kernel/vmlinux.lds.S.
   But I understand that the address of loading the kernel image is
   now be detemined dynamically (not compile time) and the INIT_TASK()
   macro still initializes the link list by wrong value :-<

2) We tried to set the current (r13) of cpu_idle to region 5 address.
   But it paniced and I could not grab the cause of the panic.
   Is there any reason we must put init_task in region 5?

Does anybody have better idea?

Best Regards, 
--
Kaigai Kohei, Linux Promotion Center, NEC
E-mail: kaigai@ak.jp.nec.com
------=_NextPart_000_013C_01C44E26.D34ED820
Content-Type: application/octet-stream;
	name="ia64.selinux.nopanic.040607.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="ia64.selinux.nopanic.040607.patch"

diff -rNU2 linux-2.6.6/arch/ia64/kernel/setup.c =
linux-2.6.6.selinux/arch/ia64/kernel/setup.c=0A=
--- linux-2.6.6/arch/ia64/kernel/setup.c	2004-05-10 11:32:01.000000000 =
+0900=0A=
+++ linux-2.6.6.selinux/arch/ia64/kernel/setup.c	2004-06-08 =
14:48:45.000000000 +0900=0A=
@@ -284,4 +284,14 @@=0A=
 setup_arch (char **cmdline_p)=0A=
 {=0A=
+	/*-----------------------------------------------------=0A=
+	 because task_struct of the parent of init(PID=3D0) was=0A=
+	 initialized statically,the members of list type=0A=
+	 in task_struct should be empty by self reference=0A=
+	 references 0xa000... But,since current is 0xe000...=0A=
+	 ,list_for_each() macro can not recognise this data=0A=
+	 as empty list. Thus,these member should be initialized=0A=
+	 dynamically. This problem was actualized in using SELinux.=0A=
+	 -----------------------------------------------------*/=0A=
+	init_waitqueue_head(&(current->wait_chldexit));=0A=
 	unw_init();=0A=
 =0A=

------=_NextPart_000_013C_01C44E26.D34ED820--

