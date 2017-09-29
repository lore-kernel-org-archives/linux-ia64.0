From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 29 Sep 2017 16:06:28 +0000
Subject: [PATCH REBASED 4/6] x86: Add __down_read_killable()
Message-Id: <150670118802.23930.1316107715255410256.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
In-Reply-To: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

Similar to __down_write_killable(), add read killable primitive:
extract current __down_read() code to macros and teach it to get
different functions as slow_path argument:
store ax register to ret, and add sp register and preserve its value.

Add call_rwsem_down_read_failed_killable() assembly entry similar
to call_rwsem_down_read_failed():
push dx register to stack in additional to common registers,
as it's not declarated as modifiable in ____down_read().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 arch/x86/include/asm/rwsem.h |   35 +++++++++++++++++++++++++----------
 arch/x86/lib/rwsem.S         |   12 ++++++++++++
 2 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index a8f486e7a124..1e51195c0b63 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -60,18 +60,33 @@
 /*
  * lock for reading
  */
+#define ____down_read(sem, slow_path)					\
+({									\
+	struct rw_semaphore* ret;					\
+	asm volatile("# beginning down_read\n\t"			\
+		     LOCK_PREFIX _ASM_INC "(%[sem])\n\t"		\
+		     /* adds 0x00000001 */				\
+		     "  jns        1f\n"				\
+		     "  call " slow_path "\n"				\
+		     "1:\n\t"						\
+		     "# ending down_read\n\t"				\
+		     : "+m" (sem->count), "=a" (ret),			\
+			ASM_CALL_CONSTRAINT				\
+		     : [sem] "a" (sem)					\
+		     : "memory", "cc");					\
+	ret;								\
+})
+
 static inline void __down_read(struct rw_semaphore *sem)
 {
-	asm volatile("# beginning down_read\n\t"
-		     LOCK_PREFIX _ASM_INC "(%[sem])\n\t"
-		     /* adds 0x00000001 */
-		     "  jns        1f\n"
-		     "  call call_rwsem_down_read_failed\n"
-		     "1:\n\t"
-		     "# ending down_read\n\t"
-		     : "+m" (sem->count)
-		     : [sem] "a" (sem)
-		     : "memory", "cc");
+	____down_read(sem, "call_rwsem_down_read_failed");
+}
+
+static inline int __down_read_killable(struct rw_semaphore *sem)
+{
+	if (IS_ERR(____down_read(sem, "call_rwsem_down_read_failed_killable")))
+		return -EINTR;
+	return 0;
 }
 
 /*
diff --git a/arch/x86/lib/rwsem.S b/arch/x86/lib/rwsem.S
index bf2c6074efd2..dc2ab6ea6768 100644
--- a/arch/x86/lib/rwsem.S
+++ b/arch/x86/lib/rwsem.S
@@ -98,6 +98,18 @@ ENTRY(call_rwsem_down_read_failed)
 	ret
 ENDPROC(call_rwsem_down_read_failed)
 
+ENTRY(call_rwsem_down_read_failed_killable)
+	FRAME_BEGIN
+	save_common_regs
+	__ASM_SIZE(push,) %__ASM_REG(dx)
+	movq %rax,%rdi
+	call rwsem_down_read_failed_killable
+	__ASM_SIZE(pop,) %__ASM_REG(dx)
+	restore_common_regs
+	FRAME_END
+	ret
+ENDPROC(call_rwsem_down_read_failed_killable)
+
 ENTRY(call_rwsem_down_write_failed)
 	FRAME_BEGIN
 	save_common_regs

