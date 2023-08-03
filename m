Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A4C0C04A6A
	for <linux-ia64@archiver.kernel.org>; Thu,  3 Aug 2023 22:47:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232738AbjHCWq7 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 3 Aug 2023 18:46:59 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39798 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232277AbjHCWp5 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 3 Aug 2023 18:45:57 -0400
Received: from mgamail.intel.com (mgamail.intel.com [192.55.52.43])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4697A2698
        for <linux-ia64@vger.kernel.org>; Thu,  3 Aug 2023 15:45:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1691102755; x=1722638755;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=0tZsfzKRM8wY7iRYRCX4Tqvn/YP7M40RRPShdXrrSgc=;
  b=G+FduiaggbCymQGuyJs9laT6UAgdQQQ5R6heqCMV8HtwRuT9ZgBEjiNm
   9mBtXJ0nl2Pmt+U/crsodjOt8Qinz+RdPJJ7KIPpK553xd6JC7ufxcmoY
   QTewDI073e1CR9EROTTPtAb3MjyaDr52kJ1+0UUjNfOZybRnnTn7ZOWB6
   3tDF1DVN9zeXbOEODwImu5OrApVjeWO8vHD59oCMo3qrxzIi3u0k5aqy4
   vlf6pd5J0s5vPwILO2qJoMsZV1igzl4vUy5rUAjQDQPus5aA6zktO9cEN
   fU19+kOyIogEv09e68E3EZYG25WZk7RBKIm/KVkUzQZY4uDrSR0MzW7XN
   g==;
X-IronPort-AV: E=McAfee;i="6600,9927,10791"; a="456386445"
X-IronPort-AV: E=Sophos;i="6.01,253,1684825200"; 
   d="scan'208";a="456386445"
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga105.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Aug 2023 15:45:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10791"; a="843793270"
X-IronPort-AV: E=Sophos;i="6.01,253,1684825200"; 
   d="scan'208";a="843793270"
Received: from lkp-server01.sh.intel.com (HELO d1ccc7e87e8f) ([10.239.97.150])
  by fmsmga002.fm.intel.com with ESMTP; 03 Aug 2023 15:45:53 -0700
Received: from kbuild by d1ccc7e87e8f with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qRh4q-0002QJ-2B;
        Thu, 03 Aug 2023 22:45:52 +0000
Date:   Fri, 4 Aug 2023 06:45:45 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
        linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65rc4 2/2]
 fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top
 level declarator
Message-ID: <202308040650.ayL6ExhZ-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65rc4
head:   36621209814f9810feed9af60d278a198847c117
commit: 36621209814f9810feed9af60d278a198847c117 [2/2] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
config: i386-randconfig-r032-20230804 (https://download.01.org/0day-ci/archive/20230804/202308040650.ayL6ExhZ-lkp@intel.com/config)
compiler: clang version 16.0.4 (https://github.com/llvm/llvm-project.git ae42196bc493ffe877a7e3dff8be32035dea4d07)
reproduce: (https://download.01.org/0day-ci/archive/20230804/202308040650.ayL6ExhZ-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202308040650.ayL6ExhZ-lkp@intel.com/

All errors (new ones prefixed by >>):

   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
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
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: incompatible pointer to integer conversion initializing 'int' with an expression of type 'void *' [-Wint-conversion]
   module_init(cat_init);
   ^~~~~~~~~~~~~~~~~~~~~
   include/linux/module.h:88:24: note: expanded from macro 'module_init'
   #define module_init(x)  __initcall(x);
                           ^~~~~~~~~~~~~
   include/linux/init.h:316:24: note: expanded from macro '__initcall'
   #define __initcall(fn) device_initcall(fn)
                          ^~~~~~~~~~~~~~~~~~~
   include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
   #define device_initcall(fn)             __define_initcall(fn, 6)
                                           ^~~~~~~~~~~~~~~~~~~~~~~~
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: redefinition of 'rdt_l3_pseudolock__215_569_cat_init6' as different kind of symbol
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
   fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: note: previous definition is here
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
>> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: '__initstub__kmod_rdt_l2_pseudolock' causes a section type conflict with 'init_rootfs'
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
   note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
   include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
   #define __PASTE(a,b) ___PASTE(a,b)
                        ^
   include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
   #define ___PASTE(a,b) a##b
                         ^
   <scratch space>:18:1: note: expanded from here
   __initstub__kmod_rdt_l2_pseudolock
   ^
   include/linux/init.h:154:13: note: declared here
   void __init init_rootfs(void);
               ^
   2 warnings and 11 errors generated.


vim +569 fs/resctrl2/arch/x86/l3_pseudolock.c

   568	
 > 569	module_init(cat_init);
   570	module_exit(cat_cleanup);
   571	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
