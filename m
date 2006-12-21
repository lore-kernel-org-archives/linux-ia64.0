From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 21 Dec 2006 03:56:10 +0000
Subject: Unable to do IA64 stacktrace in early boot
Message-Id: <5478.1166673370@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Booting 2.6.20-rc1 on IA64 with CONFIG_DEBUG_LOCKING_API_SELFTESTS=y.

| Locking API testsuite:
----------------------------------------------------------------------------
                                 | spin |wlock |rlock |mutex | wsem | rsem |
  --------------------------------------------------------------------------
                     A-A deadlock:failed|failed|  ok  |failed|failed|failed|
                 A-B-B-A deadlock:failed|failed|  ok  |failed|failed|failed|
             A-B-B-C-C-A deadlock:failed|failed|  ok  |failed|failed|failed|
             A-B-C-A-B-C deadlock:failed|failed|  ok  |failed|failed|failed|
         A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
         A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
         A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
                    double unlock:  ok  |  ok  |failed|WARNING at /build/kaos/kernel.org-sgidev/linux/kernel/mutex-debug.c:83 debug_mutex_unlock()
Unable to handle kernel NULL pointer dereference (address 0000000000000000)

mutex-debug uses DEBUG_LOCKS_WARN_ON() which indirectly calls
dump_stack which the IA64 unwind code (arch/ia64/kernel/unwind.c) calls
kmalloc.  The lockdep tests are run before the slab caches have been
allocated so cpu_cache_get is called with a NULL cachep, hence the
oops.

This problem is masked by the KDB patches because they replace the
kmalloc/kfree code in IA64 unwind with a static allocation pool.  With
KDB applied IA64 does not require the slab to be initialised before you
can do a backtrace.

If we want backtraces on IA64 before slab has been initialized then the
ia64 unwinder has to use a different allocation method.  This may also
be a problem for other architectures that use kmalloc in their unwind
code.

