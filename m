Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EA37C001DF
	for <linux-ia64@archiver.kernel.org>; Thu,  3 Aug 2023 20:53:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232269AbjHCUxC (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 3 Aug 2023 16:53:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56326 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232342AbjHCUwy (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 3 Aug 2023 16:52:54 -0400
Received: from mgamail.intel.com (mgamail.intel.com [192.55.52.88])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9CF0A1990
        for <linux-ia64@vger.kernel.org>; Thu,  3 Aug 2023 13:52:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1691095971; x=1722631971;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=vDrpjjpzhxEERYte7UClSoZmEjVM6GiQhbyDmhBPPN8=;
  b=CVEIfT3m21EWQt/CAj+QtKCbRchZp9SFO6sD9CZ2edehnI+ytp3MyFFI
   YWQF0WWIRd4TQA0cMr06GigYwpCAd5zeq3BolRCHTjYrrfu76MtK3Hz5l
   3xdjWXDm2wdxQpbEWMfc4ODdrm9FrMmtJHkvJTpZnwbhjYT+Z+8vS07fk
   RCZDX84ig8mb9pehXG7FiQc0hRC6NlE17sSUMliqG8S2POT49+5pvi6ZW
   M5VGnhKJQfriM+Ep3duOd8HgjHbZZtFHW+J71K6pYW6WMp2KBlVM/2Bpp
   qGSrPgfAhzI7duT0cdVSlMxARrUtGzOrybRZLLYZtrJnALgpe4NXr68A/
   A==;
X-IronPort-AV: E=McAfee;i="6600,9927,10791"; a="400953044"
X-IronPort-AV: E=Sophos;i="6.01,253,1684825200"; 
   d="scan'208";a="400953044"
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga101.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Aug 2023 13:52:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10791"; a="1060446759"
X-IronPort-AV: E=Sophos;i="6.01,253,1684825200"; 
   d="scan'208";a="1060446759"
Received: from lkp-server01.sh.intel.com (HELO d1ccc7e87e8f) ([10.239.97.150])
  by fmsmga005.fm.intel.com with ESMTP; 03 Aug 2023 13:52:49 -0700
Received: from kbuild by d1ccc7e87e8f with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qRfJQ-0002Lf-1h;
        Thu, 03 Aug 2023 20:52:48 +0000
Date:   Fri, 4 Aug 2023 04:52:28 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
        linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65rc4 2/2]
 fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute
 only applies to functions
Message-ID: <202308040454.KDX8XwYE-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65rc4
head:   36621209814f9810feed9af60d278a198847c117
commit: 36621209814f9810feed9af60d278a198847c117 [2/2] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
config: i386-randconfig-r032-20230804 (https://download.01.org/0day-ci/archive/20230804/202308040454.KDX8XwYE-lkp@intel.com/config)
compiler: clang version 16.0.4 (https://github.com/llvm/llvm-project.git ae42196bc493ffe877a7e3dff8be32035dea4d07)
reproduce: (https://download.01.org/0day-ci/archive/20230804/202308040454.KDX8XwYE-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202308040454.KDX8XwYE-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
   module_init(cat_init);
   ^
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/init.h:243:6: note: expanded from macro '__define_initcall_stub'
           int __init __stub(void);                                \
               ^
   include/linux/init.h:52:41: note: expanded from macro '__init'
   #define __init          __section(".init.text") __cold  __latent_entropy __noinitretpoline
                                                   ^
   include/linux/compiler_types.h:104:34: note: expanded from macro '__cold'
   #define __cold                          __attribute__((__cold__))
                                                          ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
           __unique_initcall(fn, id, __sec, __initcall_id(fn))
                                            ^
   include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
           __PASTE(__KBUILD_MODNAME,                               \
                   ^
   <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
   #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
                                                  ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
   #define __PASTE(a,b) ___PASTE(a,b)
                        ^
   include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
   #define ___PASTE(a,b) a##b
                         ^
   <scratch space>:15:1: note: expanded from here
   rdt_l3_pseudolock__215_569_cat_init6
   ^
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/init.h:244:6: note: expanded from macro '__define_initcall_stub'
           int __init __stub(void)                                 \
               ^
   include/linux/init.h:52:41: note: expanded from macro '__init'
   #define __init          __section(".init.text") __cold  __latent_entropy __noinitretpoline
                                                   ^
   include/linux/compiler_types.h:104:34: note: expanded from macro '__cold'
   #define __cold                          __attribute__((__cold__))
                                                          ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
           __unique_initcall(fn, id, __sec, __initcall_id(fn))
                                            ^
   include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
           __PASTE(__KBUILD_MODNAME,                               \
                   ^
   <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
   #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
                                                  ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
   #define __PASTE(a,b) ___PASTE(a,b)
                        ^
   include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
   #define ___PASTE(a,b) a##b
                         ^
   <scratch space>:15:1: note: expanded from here
   rdt_l3_pseudolock__215_569_cat_init6
   ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
           __unique_initcall(fn, id, __sec, __initcall_id(fn))
                                            ^
   include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
           __PASTE(__KBUILD_MODNAME,                               \
                   ^
   <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
   #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
                                                  ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^
   note: (skipping 8 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
   #define __PASTE(a,b) ___PASTE(a,b)
                        ^
   include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
   #define ___PASTE(a,b) a##b
                         ^
   <scratch space>:28:1: note: expanded from here
   rdt_l3_pseudolock__215_569_cat_init6216
   ^
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: incompatible pointer to integer conversion initializing 'int' with an expression of type 'void *' [-Wint-conversion]


vim +/__cold__ +569 fs/resctrl2/arch/x86/l3_pseudolock.c

   568	
 > 569	module_init(cat_init);
   570	module_exit(cat_cleanup);
   571	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
