From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Mar 2003 10:35:48 +0000
Subject: Re: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806056@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 Mar 2003 21:19:37 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>This patch against 2.4.20-ia64-021220 has had minimal testing, it works
>for me (TM)....
>This code works for spin_lock() in built in code and for modules...

Index: 20.5/arch/ia64/kernel/ia64_ksyms.c
--- 20.5/arch/ia64/kernel/ia64_ksyms.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/r/c/35_ia64_ksyms 1.1.3.1.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/ia64_ksyms.c Wed, 12 Mar 2003 17:28:13 +1100 kaos (linux-2.4/r/c/35_ia64_ksyms 1.1.3.1.3.1.1.1.1.3 644)
@@ -165,3 +165,9 @@ EXPORT_SYMBOL(machvec_noop);
 EXPORT_SYMBOL(pfm_install_alternate_syswide_subsystem);
 EXPORT_SYMBOL(pfm_remove_alternate_syswide_subsystem);
 #endif
+
+/* Spinlock contention path is entered via direct branch, not using a function
+ * pointer.  Fudge the declaration so we do not generate a function descriptor.
+ */
+extern char ia64_spinlock_contention[];
+EXPORT_SYMBOL(ia64_spinlock_contention);

That last EXPORT_SYMBOL should be EXPORT_SYMBOL_NOVERS, asm exports do
not have versions.


