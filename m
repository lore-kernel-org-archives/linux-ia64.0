From: john stultz <johnstul@us.ibm.com>
Date: Fri, 15 Feb 2002 21:03:21 +0000
Subject: [Linux-ia64] doh! NMCS patches attached.
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-Xz4tgRVCoWUHS0Bw9u38"
Message-Id: <marc-linux-ia64-105590701905118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--=-Xz4tgRVCoWUHS0Bw9u38
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

<smack>
-john


--=-Xz4tgRVCoWUHS0Bw9u38
Content-Disposition: attachment; filename=mcslock-2.4.17-C1.patch
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=ISO-8859-1

Index: linux24/include/asm-ia64/processor.h
diff -u linux24/include/asm-ia64/processor.h:1.1.1.1 linux24/include/asm-ia=
64/processor.h:1.1.1.1.20.1
--- linux24/include/asm-ia64/processor.h:1.1.1.1	Tue Dec 18 15:49:04 2001
+++ linux24/include/asm-ia64/processor.h	Fri Feb 15 09:56:30 2002
@@ -547,6 +547,8 @@
 extern void ia64_load_pm_regs (struct task_struct *task);
 #endif
=20
+#define rep_nop() /*not an ia64 op*/
+
 #define ia64_fph_enable()	asm volatile (";; rsm psr.dfh;; srlz.d;;" ::: "m=
emory");
 #define ia64_fph_disable()	asm volatile (";; ssm psr.dfh;; srlz.d;;" ::: "=
memory");
=20
Index: linux24/include/linux/mcslock.h
diff -u /dev/null linux24/include/linux/mcslock.h:1.1.4.11
--- /dev/null	Fri Feb 15 12:15:44 2002
+++ linux24/include/linux/mcslock.h	Fri Feb 15 09:54:13 2002
@@ -0,0 +1,158 @@
+/*
+	MCS and Nodeless MCS Lock implementations.=20
+	John Stultz (johnstul@us.ibm.com)
+=09
+	New Nodeless MCS Lock origianally designed for K42 by
+	Marc Auslander, David Edelsohn, Orran Y Krieger,=20
+	Bryan S Rosenburg, and Robert W Wisniewski.
+	http://www.research.ibm.com/K42/
+=09
+*/
+#ifndef _MCS_LOCKS_H
+#define _MCS_LOCKS_H
+
+#include <linux/types.h>
+#include <asm/bitops.h>
+#include <asm/system.h>
+#include <asm/smp.h>
+#include <asm/processor.h>
+
+/*=3D=3D[MCS Lock]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
+struct mcsnode_t {
+	struct mcsnode_t* volatile  next;
+	volatile int flag;
+};
+typedef struct mcsnode_t* volatile mcslock_t;
+typedef struct mcsnode_t mcsnode_t;
+
+#define MCS_LOCK_UNLOCKED (mcslock_t) NULL
+#define MCS_NODE_UNLOCKED (mcsnode_t) {NULL, 0}
+
+#define mcs_lock_init(x)	do { *(x) =3D MCS_LOCK_UNLOCKED; } while(0)
+#define mcs_is_locked(x)	((*(mcsnode_t*)(x))!=3DNULL)
+#define mcs_unlock_wait(x)	do {barrier();} while(mcs_is_locked(x))
+
+#define mcs_lock_irq(x,y) \
+	do { local_irq_disable(); mcs_lock(x,y); } while(0)
+#define mcs_unlock_irq(x,y) \
+	do { mcs_unlock(x,y); local_irq_enable(); } while(0)
+#define mcs_lock_irqsave(x,y,flags) \
+	do { local_irq_save(flags); mcs_lock(x,y); } while(0)
+#define mcs_unlock_irqrestore(x,y,flags) \
+	do { mcs_unlock(x,y); local_irq_restore(flags); } while(0)
+
+#ifndef CONFIG_SMP
+/*UP nops*/
+#define mcs_lock(x,y) (void*)(y)
+#define mcs_trylock(x,y) (1)
+#define mcs_unlock(x,y) (void*)(x)
+=09
+#else /*!CONFIG_SMP*/
+
+extern void mcs_lock(mcslock_t* lock,  mcsnode_t* instance);
+static inline void __mcs_lock(mcslock_t* lock,  mcsnode_t* instance)
+{
+	mcsnode_t* before;=20
+	instance->next =3D NULL;
+	before =3D xchg((mcsnode_t**)lock,instance);
+	if (before !=3D NULL)	{
+		instance->flag =3D 1;
+		before->next =3D instance;
+		while(instance->flag){rep_nop();}
+	}
+}
+
+extern int  mcs_trylock(mcslock_t* lock, mcsnode_t* instance);
+static inline int  __mcs_trylock(mcslock_t* lock, mcsnode_t* instance)
+{
+	if(NULL =3D=3D cmpxchg(lock,NULL,instance))
+		return 1;
+	return 0;
+}
+
+extern void mcs_unlock(mcslock_t* lock, mcsnode_t* instance);
+static inline void __mcs_unlock(mcslock_t* lock, mcsnode_t* instance)
+{
+	if(instance->next =3D=3D NULL) {
+		if(instance =3D=3D cmpxchg(lock,instance,NULL))
+			return;
+		while(instance->next =3D=3D NULL){rep_nop();}
+	}
+	wmb();
+	instance->next->flag =3D 0;
+}
+#endif /*!CONFIG_SMP*/
+
+
+/*=3D=3D[Nodeless MCS Lock]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D*/
+
+struct nmcslock_t{
+	mcsnode_t holder;
+	mcslock_t list;
+};
+
+typedef struct nmcslock_t nmcslock_t;
+
+#define NMCS_LOCK_UNLOCKED (nmcslock_t) {MCS_NODE_UNLOCKED,MCS_LOCK_UNLOCK=
ED}
+
+#define nmcs_lock_init(x)	do { *(x) =3D NMCS_LOCK_UNLOCKED; } while(0)
+#define nmcs_is_locked(x)	((x)->list !=3D 0)
+#define nmcs_unlock_wait(x)	do {barrier();} while(nmcs_is_locked(x))
+
+
+#ifndef CONFIG_SMP
+/*UP nops*/
+#define nmcs_lock(x) (void*)(x)
+#define nmcs_trylock(x) (1)
+#define nmcs_unlock(x) (void*)(x)
+
+#else /*!CONFIG_SMP*/
+
+extern void nmcs_lock(nmcslock_t* lock);
+static inline void __nmcs_lock(nmcslock_t* lock)
+{
+	while(1){
+		if(NULL =3D=3D cmpxchg(&lock->list, NULL, &lock->holder)){
+			return;
+		}else{
+			mcsnode_t instance =3D MCS_NODE_UNLOCKED;		=09
+			mcsnode_t* before =3D (mcsnode_t*)lock->list;
+			if(before && (before =3D=3D cmpxchg(&lock->list, before, &instance)))
+			{
+				instance.flag =3D 1;
+				before->next =3D &instance;
+				while(instance.flag){rep_nop();}
+				lock->holder.next =3D NULL;
+				if(&instance !=3D cmpxchg(&lock->list, &instance, &lock->holder)){
+					while(!instance.next){rep_nop();}
+					lock->holder.next =3D instance.next;
+				}
+				return;
+			}
+		}
+		/*whoops! the list changed on us. try again*/
+	}
+}
+
+extern int nmcs_trylock(nmcslock_t* lock);
+static inline int __nmcs_trylock(nmcslock_t* lock)
+{
+	if(NULL =3D=3D cmpxchg(&lock->list, NULL, &lock->holder))
+		return 1;
+	return 0;=09
+}
+
+extern void nmcs_unlock(nmcslock_t* lock);
+static inline void __nmcs_unlock(nmcslock_t* lock)
+{
+	wmb();
+	if(&lock->holder !=3D cmpxchg(&lock->list, &lock->holder, NULL))
+	{
+		while(lock->holder.next =3D=3D NULL){rep_nop();}
+		lock->holder.next->flag =3D 0;
+	}
+}
+
+#endif /*!CONFIG_SMP*/
+
+#endif /*!_MCS_LOCKS_H*/
Index: linux24/lib/Makefile
diff -u linux24/lib/Makefile:1.1.1.1 linux24/lib/Makefile:1.1.1.1.18.1
--- linux24/lib/Makefile:1.1.1.1	Tue Dec 18 15:49:00 2001
+++ linux24/lib/Makefile	Tue Feb 12 14:15:38 2002
@@ -10,7 +10,7 @@
=20
 export-objs :=3D cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o
=20
-obj-y :=3D errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spi=
nlocks.o rbtree.o
+obj-y :=3D errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spi=
nlocks.o rbtree.o mcslock.o
=20
 obj-$(CONFIG_RWSEM_GENERIC_SPINLOCK) +=3D rwsem-spinlock.o
 obj-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) +=3D rwsem.o
Index: linux24/lib/mcslock.c
diff -u /dev/null linux24/lib/mcslock.c:1.1.4.1
--- /dev/null	Fri Feb 15 12:15:44 2002
+++ linux24/lib/mcslock.c	Tue Feb 12 14:15:38 2002
@@ -0,0 +1,31 @@
+#include <linux/mcslock.h>
+
+/*non inlined versions of mcs lock*/
+void mcs_lock(mcslock_t* lock,  mcsnode_t* instance)
+{
+	__mcs_lock(lock, instance);
+}
+int  mcs_trylock(mcslock_t* lock, mcsnode_t* instance)
+{
+	return __mcs_trylock(lock, instance);
+}
+void mcs_unlock(mcslock_t* lock, mcsnode_t* instance)
+{
+	__mcs_unlock(lock, instance);
+}
+
+/*non inlined versions of nodeless mcs lock*/
+void nmcs_lock(nmcslock_t* lock)
+{
+	__nmcs_lock(lock);
+}
+
+int nmcs_trylock(nmcslock_t* lock)
+{
+	return __nmcs_trylock(lock);
+}
+
+void nmcs_unlock(nmcslock_t* lock)
+{
+	__nmcs_unlock(lock);
+}

--=-Xz4tgRVCoWUHS0Bw9u38
Content-Disposition: attachment; filename=spinlocks-replaced-2.4.17-C1.patch
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=ISO-8859-1

Index: linux24/include/asm-i386/spinlock.h
diff -u linux24/include/asm-i386/spinlock.h:1.1.1.1 linux24/include/asm-i38=
6/spinlock.h:1.1.1.1.22.1
--- linux24/include/asm-i386/spinlock.h:1.1.1.1	Tue Dec 18 15:49:01 2001
+++ linux24/include/asm-i386/spinlock.h	Fri Jan 25 11:57:13 2002
@@ -23,6 +23,8 @@
  * Your basic SMP spinlocks, allowing only a single CPU anywhere
  */
=20
+#define USE_NMCS_LOCK
+#ifndef USE_NMCS_LOCK
 typedef struct {
 	volatile unsigned int lock;
 #if SPINLOCK_DEBUG
@@ -137,7 +139,20 @@
 		spin_lock_string
 		:"=3Dm" (lock->lock) : : "memory");
 }
+#else /*!USE_NMCS_LOCK*/
+#include <linux/mcslock.h>
+#define spinlock_t nmcslock_t
+#define SPIN_LOCK_UNLOCKED NMCS_LOCK_UNLOCKED
+
+#define spin_lock_init(x)	nmcs_lock_init(x)=09
+#define spin_is_locked(x)	nmcs_is_locked(x)
+#define spin_unlock_wait(x)	nmcs_unlock_wait(x)
+
+#define spin_lock(x)	nmcs_lock(x)
+#define spin_trylock(x)	nmcs_trylock(x)=20
+#define spin_unlock(x)	nmcs_unlock(x)=20
=20
+#endif
=20
 /*
  * Read-write spinlocks, allowing multiple readers
Index: linux24/include/asm-ia64/spinlock.h
diff -u linux24/include/asm-ia64/spinlock.h:1.1.1.1 linux24/include/asm-ia6=
4/spinlock.h:1.1.1.1.22.1
--- linux24/include/asm-ia64/spinlock.h:1.1.1.1	Tue Dec 18 15:49:04 2001
+++ linux24/include/asm-ia64/spinlock.h	Tue Jan 29 15:58:02 2002
@@ -67,6 +67,8 @@
=20
 #else /* !NEW_LOCK */
=20
+#define USE_NMCS_LOCK
+#ifndef USE_NMCS_LOCK
 typedef struct {
 	volatile unsigned int lock;
 } spinlock_t;
@@ -99,7 +101,20 @@
 #define spin_unlock(x)		do { barrier(); ((spinlock_t *) x)->lock =3D 0; } =
while (0)
 #define spin_trylock(x)		(cmpxchg_acq(&(x)->lock, 0, 1) =3D=3D 0)
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)
+#else /*!USE_NMCS_LOCK*/
+#include <linux/mcslock.h>
+#define spinlock_t nmcslock_t
+#define SPIN_LOCK_UNLOCKED NMCS_LOCK_UNLOCKED
=20
+#define spin_lock_init(x)	nmcs_lock_init(x)=09
+#define spin_is_locked(x)	nmcs_is_locked(x)
+#define spin_unlock_wait(x)	nmcs_unlock_wait(x)
+
+#define spin_lock(x)	nmcs_lock(x)
+#define spin_trylock(x)	nmcs_trylock(x)=20
+#define spin_unlock(x)	nmcs_unlock(x)=20
+
+#endif
 #endif /* !NEW_LOCK */
=20
 typedef struct {

--=-Xz4tgRVCoWUHS0Bw9u38--


