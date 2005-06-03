From: Keith Owens <kaos@sgi.com>
Date: Fri, 03 Jun 2005 07:15:54 +0000
Subject: Re: periodically-drain-non-local-pagesets-fix.patch added to -mm tree
Message-Id: <13960.1117782954@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050602231057.580dcaa3.akpm@osdl.org>
In-Reply-To: <20050602231057.580dcaa3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 2 Jun 2005 23:10:57 -0700,=20
Andrew Morton <akpm@osdl.org> wrote:
>
>(added linux-ia64)
>
>Christoph Lameter <clameter@engr.sgi.com> wrote:
>>
>> printk: 272 messages suppressed.
>>  BUG: using smp_processor_id() in preemptible [00000001] code:=20
>>  K10boot.swap/14959
>>  caller is ia64_flush_fph+0x40/0x1a0
>>=20
>>  Call Trace:
>>   [<a000000100010840>] show_stack+0x80/0xa0
>>                                  sp=E000023c1571fb20 bsp=E000023c15719158
>>   [<a000000100010890>] dump_stack+0x30/0x60
>>                                  sp=E000023c1571fcf0 bsp=E000023c15719148
>>   [<a0000001003f3be0>] debug_smp_processor_id+0x2a0/0x2c0
>>                                  sp=E000023c1571fcf0 bsp=E000023c15719128
>>   [<a00000010002f6c0>] ia64_flush_fph+0x40/0x1a0
>>                                  sp=E000023c1571fd70 bsp=E000023c15719110
>>   [<a000000100035060>] setup_sigcontext+0x80/0x5e0
>>                                  sp=E000023c1571fd80 bsp=E000023c157190c8
>>   [<a000000100035aa0>] setup_frame+0x3a0/0x4a0
>>                                  sp=E000023c1571fd80 bsp=E000023c15719068
>>   [<a000000100035d30>] handle_signal+0x190/0x1a0
>>                                  sp=E000023c1571fd80 bsp=E000023c15719030
>>   [<a000000100035e80>] ia64_do_signal+0x140/0x400
>>                                  sp=E000023c1571fd80 bsp=E000023c15718f88
>>   [<a000000100011250>] do_notify_resume_user+0x110/0x120
>
>Seems to me to be a preempt bug in the ia64 code:
>
>inline void
>ia64_flush_fph (struct task_struct *task)
>{
>	struct ia64_psr *psr =3D ia64_psr(ia64_task_regs(task));
>
>	if (ia64_is_local_fpu_owner(task) && psr->mfh) {
>		psr->mfh =3D 0;
>		task->thread.flags |=3D IA64_THREAD_FPH_VALID;
>		ia64_save_fpu(&task->thread.fph[0]);
>	}
>}
>
>ia64_is_local_fpu_owner() diddles around with the concept of "the CPU we're
>running on", but as no locks are held, smp_processor_id() can change at any
>time.

Does this fix the problem?  Compiled but not tested.

Index: linux/include/asm-ia64/processor.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/processor.h	2005-06=
-03 13:05:48.421839027 +1000
+++ linux/include/asm-ia64/processor.h	2005-06-03 17:10:43.911784989 +1000
@@ -407,15 +407,18 @@ extern void ia64_setreg_unknown_kr (void
 #define ia64_is_local_fpu_owner(t)								\
 ({												\
 	struct task_struct *__ia64_islfo_task =3D (t);						\
-	(__ia64_islfo_task->thread.last_fph_cpu =3D smp_processor_id()				\
+	int ret =3D (__ia64_islfo_task->thread.last_fph_cpu =3D get_cpu()				\
 	 && __ia64_islfo_task =3D (struct task_struct *) ia64_get_kr(IA64_KR_FPU_=
OWNER));	\
+	put_cpu();										\
+	ret;											\
 })
=20
 /* Mark task T as owning the fph partition of the CPU we're running on. */
 #define ia64_set_local_fpu_owner(t) do {						\
 	struct task_struct *__ia64_slfo_task =3D (t);					\
-	__ia64_slfo_task->thread.last_fph_cpu =3D smp_processor_id();			\
+	__ia64_slfo_task->thread.last_fph_cpu =3D get_cpu();				\
 	ia64_set_kr(IA64_KR_FPU_OWNER, (unsigned long) __ia64_slfo_task);		\
+	put_cpu();									\
 } while (0)
=20
 /* Mark the fph partition of task T as being invalid on all CPUs.  */

