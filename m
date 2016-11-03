From: kbuild test robot <lkp@intel.com>
Date: Thu, 03 Nov 2016 16:22:52 +0000
Subject: Re: [PATCH 16/25] ia64/salinfo: Convert to hotplug state machine
Message-Id: <201611040028.tdLmuVrI%fengguang.wu@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
List-Id: <linux-ia64.vger.kernel.org>
References: <20161103145021.28528-17-bigeasy@linutronix.de>
In-Reply-To: <20161103145021.28528-17-bigeasy@linutronix.de>
To: linux-ia64@vger.kernel.org


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sebastian,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.9-rc3]
[cannot apply to next-20161028]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Sebastian-Andrzej-Siewior/fs-buffer-Convert-to-hotplug-state-machine/20161103-230222
config: ia64-allnoconfig (attached as .config)
compiler: ia64-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=ia64 

All warnings (new ones prefixed by >>):

   In file included from include/linux/kernel.h:12:0,
                    from include/linux/list.h:8,
                    from include/linux/kobject.h:20,
                    from include/linux/device.h:17,
                    from include/linux/node.h:17,
                    from include/linux/cpu.h:16,
                    from arch/ia64/kernel/salinfo.c:40:
   arch/ia64/kernel/salinfo.c: In function 'salinfo_cpu_pre_down':
   arch/ia64/kernel/salinfo.c:572:38: error: 'flags' undeclared (first use in this function)
     spin_lock_irqsave(&data_saved_lock, flags);
                                         ^
   include/linux/typecheck.h:10:9: note: in definition of macro 'typecheck'
     typeof(x) __dummy2; \
            ^
   include/linux/spinlock.h:337:2: note: in expansion of macro 'raw_spin_lock_irqsave'
     raw_spin_lock_irqsave(spinlock_check(lock), flags); \
     ^~~~~~~~~~~~~~~~~~~~~
   arch/ia64/kernel/salinfo.c:572:2: note: in expansion of macro 'spin_lock_irqsave'
     spin_lock_irqsave(&data_saved_lock, flags);
     ^~~~~~~~~~~~~~~~~
   arch/ia64/kernel/salinfo.c:572:38: note: each undeclared identifier is reported only once for each function it appears in
     spin_lock_irqsave(&data_saved_lock, flags);
                                         ^
   include/linux/typecheck.h:10:9: note: in definition of macro 'typecheck'
     typeof(x) __dummy2; \
            ^
   include/linux/spinlock.h:337:2: note: in expansion of macro 'raw_spin_lock_irqsave'
     raw_spin_lock_irqsave(spinlock_check(lock), flags); \
     ^~~~~~~~~~~~~~~~~~~~~
   arch/ia64/kernel/salinfo.c:572:2: note: in expansion of macro 'spin_lock_irqsave'
     spin_lock_irqsave(&data_saved_lock, flags);
     ^~~~~~~~~~~~~~~~~
   include/linux/typecheck.h:11:18: warning: comparison of distinct pointer types lacks a cast
     (void)(&__dummy == &__dummy2); \
                     ^
   include/linux/spinlock.h:229:3: note: in expansion of macro 'typecheck'
      typecheck(unsigned long, flags); \
      ^~~~~~~~~
   include/linux/spinlock.h:337:2: note: in expansion of macro 'raw_spin_lock_irqsave'
     raw_spin_lock_irqsave(spinlock_check(lock), flags); \
     ^~~~~~~~~~~~~~~~~~~~~
   arch/ia64/kernel/salinfo.c:572:2: note: in expansion of macro 'spin_lock_irqsave'
     spin_lock_irqsave(&data_saved_lock, flags);
     ^~~~~~~~~~~~~~~~~
   include/linux/typecheck.h:11:18: warning: comparison of distinct pointer types lacks a cast
     (void)(&__dummy == &__dummy2); \
                     ^
>> include/linux/irqflags.h:63:3: note: in expansion of macro 'typecheck'
      typecheck(unsigned long, flags); \
      ^~~~~~~~~
   include/linux/irqflags.h:124:3: note: in expansion of macro 'raw_local_irq_save'
      raw_local_irq_save(flags);   \
      ^~~~~~~~~~~~~~~~~~
   include/linux/spinlock_api_up.h:40:8: note: in expansion of macro 'local_irq_save'
      do { local_irq_save(flags); __LOCK(lock); } while (0)
           ^~~~~~~~~~~~~~
   include/linux/spinlock_api_up.h:69:45: note: in expansion of macro '__LOCK_IRQSAVE'
    #define _raw_spin_lock_irqsave(lock, flags) __LOCK_IRQSAVE(lock, flags)
                                                ^~~~~~~~~~~~~~
   include/linux/spinlock.h:230:3: note: in expansion of macro '_raw_spin_lock_irqsave'
      _raw_spin_lock_irqsave(lock, flags); \
      ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/spinlock.h:337:2: note: in expansion of macro 'raw_spin_lock_irqsave'
     raw_spin_lock_irqsave(spinlock_check(lock), flags); \
     ^~~~~~~~~~~~~~~~~~~~~
   arch/ia64/kernel/salinfo.c:572:2: note: in expansion of macro 'spin_lock_irqsave'
     spin_lock_irqsave(&data_saved_lock, flags);
     ^~~~~~~~~~~~~~~~~

vim +/typecheck +63 include/linux/irqflags.h

6cd8a4bb Steven Rostedt 2008-05-12  47  #if defined(CONFIG_IRQSOFF_TRACER) || \
6cd8a4bb Steven Rostedt 2008-05-12  48  	defined(CONFIG_PREEMPT_TRACER)
81d68a96 Steven Rostedt 2008-05-12  49   extern void stop_critical_timings(void);
81d68a96 Steven Rostedt 2008-05-12  50   extern void start_critical_timings(void);
81d68a96 Steven Rostedt 2008-05-12  51  #else
81d68a96 Steven Rostedt 2008-05-12  52  # define stop_critical_timings() do { } while (0)
81d68a96 Steven Rostedt 2008-05-12  53  # define start_critical_timings() do { } while (0)
81d68a96 Steven Rostedt 2008-05-12  54  #endif
81d68a96 Steven Rostedt 2008-05-12  55  
df9ee292 David Howells  2010-10-07  56  /*
df9ee292 David Howells  2010-10-07  57   * Wrap the arch provided IRQ routines to provide appropriate checks.
df9ee292 David Howells  2010-10-07  58   */
df9ee292 David Howells  2010-10-07  59  #define raw_local_irq_disable()		arch_local_irq_disable()
df9ee292 David Howells  2010-10-07  60  #define raw_local_irq_enable()		arch_local_irq_enable()
df9ee292 David Howells  2010-10-07  61  #define raw_local_irq_save(flags)			\
df9ee292 David Howells  2010-10-07  62  	do {						\
df9ee292 David Howells  2010-10-07 @63  		typecheck(unsigned long, flags);	\
df9ee292 David Howells  2010-10-07  64  		flags = arch_local_irq_save();		\
df9ee292 David Howells  2010-10-07  65  	} while (0)
df9ee292 David Howells  2010-10-07  66  #define raw_local_irq_restore(flags)			\
df9ee292 David Howells  2010-10-07  67  	do {						\
df9ee292 David Howells  2010-10-07  68  		typecheck(unsigned long, flags);	\
df9ee292 David Howells  2010-10-07  69  		arch_local_irq_restore(flags);		\
df9ee292 David Howells  2010-10-07  70  	} while (0)
df9ee292 David Howells  2010-10-07  71  #define raw_local_save_flags(flags)			\

:::::: The code at line 63 was first introduced by commit
:::::: df9ee29270c11dba7d0fe0b83ce47a4d8e8d2101 Fix IRQ flag handling naming

:::::: TO: David Howells <dhowells@redhat.com>
:::::: CC: David Howells <dhowells@redhat.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--EeQfGwPcQSOJBaQU
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--EeQfGwPcQSOJBaQU--
