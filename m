From: "Kaigai Kohei" <kaigai@ak.jp.nec.com>
Date: Tue, 15 Jun 2004 09:37:25 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <019e01c452bc$5ec3b530$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_019B_01C45307.CDDA0370"
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_019B_01C45307.CDDA0370
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Dear David

The attached patch moves the current of cpu_idle from region 7 to region 5.

The init_task can be viewed from either region 5 or 7.
But the current(r13) of cpu_idle was a region 7 address while &init_task
referes to a region 5 address. Thus, some bad effects occurred.
(This problem came to the front first time by enabling SELinux.)


Signed-off-by: Kazuto MIYOSHI <k-miyoshi@cb.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Signed-off-by: Kaigai Kohei <kaigai@ak.jp.nec.com>

Thanks, so much.
--------
Kaigai Kohei, Linux Promotion Center, NEC
E-mail: kaigai@ak.jp.nec.com


> Hi Kaigai,
> 
> Thanks for looking into this issue.
> 
> >>>>> On Tue, 15 Jun 2004 11:28:14 +0900, "Kaigai Kohei" <kaigai@ak.jp.nec.com> said:
> 
>   Kaigai> I have applied this patch to 2.6.6 kernel, and system stall
>   Kaigai> occurred while booting up. The problem is in
>   Kaigai> init_mount_tree().  The init_mount_tree() function uses
>   Kaigai> do_each_thread() macro defined as follows:
> 
>   Kaigai> #define do_each_thread(g, t) \
>   Kaigai>   for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
> 
> Yeah, that'd do it.
> 
>   Kaigai> There are several solutions against this problem.
> 
>   Kaigai> (1) Initializing only wait_chldexit as my first patch.
> 
>   Kaigai> (2) Moving current of swapper from region 7 to region 5 as
>   Kaigai> Miyoshi's second patch.
> 
>   Kaigai> (3) Replacing &init_task with task_t *p_init_task which
>   Kaigai> refers to init_task in region 7, and refers to init_task
>   Kaigai> directly on other archtectures.
> 
>   Kaigai> (1) is easy but ad hoc. (3) needs to correct generic code.
>   Kaigai> (2) is consistent on &init_task is in region 5 and
>   Kaigai> current(r13) for cpu_idle refers to region 5. But the number
>   Kaigai> of steps in switch_to() macro will increase.  This overhead
>   Kaigai> is not a big problem, I guess.
> 
>   Kaigai> For reasons already stated I prefer (2). What do you think?
> 
> I agree, (2) seems to best solution so far.  It maintains the
> invariant that static data will be in region 5.  The extra
> instructions should be pretty much free since it should be possible to
> schedule them into existing stalls.
> 
> Can you resend the tested patch with proper changelog and "Signed-off-by"
> trailer?
> 
> Thanks,
> 
> --david
> 
------=_NextPart_000_019B_01C45307.CDDA0370
Content-Type: application/octet-stream;
	name="migrate.init_task.2.6.7-rc3.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="migrate.init_task.2.6.7-rc3.patch"

diff -rNU2 linux-2.6.7-rc3/arch/ia64/kernel/entry.S =
linux-2.6.7-rc3.selinux/arch/ia64/kernel/entry.S=0A=
--- linux-2.6.7-rc3/arch/ia64/kernel/entry.S	2004-06-08 =
04:14:02.000000000 +0900=0A=
+++ linux-2.6.7-rc3.selinux/arch/ia64/kernel/entry.S	2004-06-15 =
15:19:24.925797780 +0900=0A=
@@ -178,5 +178,8 @@=0A=
 	DO_SAVE_SWITCH_STACK=0A=
 	.body=0A=
-=0A=
+	=0A=
+	movl r22=3Dinit_task;;=0A=
+	cmp.eq p7,p6=3Dr22,in0=0A=
+	=0A=
 	adds r22=3DIA64_TASK_THREAD_KSP_OFFSET,r13=0A=
 	mov r27=3DIA64_KR(CURRENT_STACK)=0A=
@@ -190,5 +193,5 @@=0A=
 	 * If we've already mapped this task's page, we can skip doing it =
again.=0A=
 	 */=0A=
-	cmp.eq p7,p6=3Dr26,r27=0A=
+(p6)	cmp.eq p7,p6=3Dr26,r27=0A=
 (p6)	br.cond.dpnt .map=0A=
 	;;=0A=
diff -rNU2 linux-2.6.7-rc3/arch/ia64/kernel/head.S =
linux-2.6.7-rc3.selinux/arch/ia64/kernel/head.S=0A=
--- linux-2.6.7-rc3/arch/ia64/kernel/head.S	2004-06-08 =
04:14:42.000000000 +0900=0A=
+++ linux-2.6.7-rc3.selinux/arch/ia64/kernel/head.S	2004-06-15 =
15:15:57.434480607 +0900=0A=
@@ -182,4 +182,6 @@=0A=
 =0A=
 	// load the "current" pointer (r13) and ar.k6 with the current task=0A=
+	(isBP) movl r2=3Dinit_task	// migrate to region 5=0A=
+	;; =0A=
 	mov IA64_KR(CURRENT)=3Dr2		// virtual address=0A=
 	mov IA64_KR(CURRENT_STACK)=3Dr16=0A=

------=_NextPart_000_019B_01C45307.CDDA0370--

