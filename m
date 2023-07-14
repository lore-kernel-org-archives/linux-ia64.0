Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3D26EB64DD
	for <linux-ia64@archiver.kernel.org>; Fri, 14 Jul 2023 02:46:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232573AbjGNCqX (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 13 Jul 2023 22:46:23 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56890 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229580AbjGNCqW (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 13 Jul 2023 22:46:22 -0400
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 711D8272E
        for <linux-ia64@vger.kernel.org>; Thu, 13 Jul 2023 19:46:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1689302781; x=1720838781;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=ZlHkugwqfb1QuSXe+Rju5wrbeYoINA3MoKkX0C6otDI=;
  b=jk8rwbXji7bYqytML6Xhtj9+pemW1Zo1W+1QsxMQPm1M4yXpgMN1Myxq
   9ydc9BVkUjYj+bBvTcwvJJJu+V7mPY0ZRV2k5gnX26H19On38lGrvh5/s
   a8m65+KdjZ/UUnAgryPCWGvfXQffR6HgFFc9zlpUoeG1ZSNSGvDO5iBSu
   OBvhH7lBhRSbqe2v1nmw4f34NcYUnmeOA05hAuaVx+VILax7wlqHCdguu
   RAtob1x+pDwU/AS3hZFMHp0QjQFE7oUxXX1p3NR27l8Bxx/I/IwA6raP3
   L7vRh8A6/mnVDTii/665oIZcZkHaeJ8dYK4Tpkn4/Ik4L6iVHcGV2a2aj
   w==;
X-IronPort-AV: E=McAfee;i="6600,9927,10770"; a="365411735"
X-IronPort-AV: E=Sophos;i="6.01,204,1684825200"; 
   d="scan'208";a="365411735"
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 13 Jul 2023 19:46:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10770"; a="1052882394"
X-IronPort-AV: E=Sophos;i="6.01,204,1684825200"; 
   d="scan'208";a="1052882394"
Received: from lkp-server01.sh.intel.com (HELO c544d7fc5005) ([10.239.97.150])
  by fmsmga005.fm.intel.com with ESMTP; 13 Jul 2023 19:46:19 -0700
Received: from kbuild by c544d7fc5005 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qK8p0-000765-2i;
        Fri, 14 Jul 2023 02:46:18 +0000
Date:   Fri, 14 Jul 2023 10:45:42 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65rc1 10/10]
 arch/riscv/include/asm/cacheinfo.h:17:11: error: conflicting types for
 'get_cache_size'; have 'uintptr_t(u32,  enum cache_type)' {aka 'long
 unsigned int(unsigned int,  enum cache_type)'}
Message-ID: <202307141026.5ORwMP1Y-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65rc1
head:   b9c1779deb41e52476fa9d9d61645168d11ef092
commit: b9c1779deb41e52476fa9d9d61645168d11ef092 [10/10] resctrl2: Add the "size" file to control groups
config: riscv-allyesconfig (https://download.01.org/0day-ci/archive/20230714/202307141026.5ORwMP1Y-lkp@intel.com/config)
compiler: riscv64-linux-gcc (GCC) 12.3.0
reproduce: (https://download.01.org/0day-ci/archive/20230714/202307141026.5ORwMP1Y-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202307141026.5ORwMP1Y-lkp@intel.com/

All errors (new ones prefixed by >>):

   scripts/genksyms/parse.y: warning: 9 shift/reduce conflicts [-Wconflicts-sr]
   scripts/genksyms/parse.y: warning: 5 reduce/reduce conflicts [-Wconflicts-rr]
   scripts/genksyms/parse.y: note: rerun with option '-Wcounterexamples' to generate conflict counterexamples
   In file included from arch/riscv/include/asm/elf.h:16,
                    from include/linux/elf.h:6,
                    from include/linux/module.h:19,
                    from include/linux/device/driver.h:21,
                    from include/linux/device.h:32,
                    from include/linux/blk_types.h:11,
                    from include/linux/writeback.h:13,
                    from include/linux/memcontrol.h:22,
                    from include/linux/swap.h:9,
                    from include/linux/suspend.h:5,
                    from arch/riscv/kernel/asm-offsets.c:12:
>> arch/riscv/include/asm/cacheinfo.h:17:11: error: conflicting types for 'get_cache_size'; have 'uintptr_t(u32,  enum cache_type)' {aka 'long unsigned int(unsigned int,  enum cache_type)'}
      17 | uintptr_t get_cache_size(u32 level, enum cache_type type);
         |           ^~~~~~~~~~~~~~
   In file included from arch/riscv/include/asm/cacheinfo.h:9:
   include/linux/cacheinfo.h:83:5: note: previous declaration of 'get_cache_size' with type 'int(int,  int)'
      83 | int get_cache_size(int cpu, int cache_level);
         |     ^~~~~~~~~~~~~~
   make[3]: *** [scripts/Makefile.build:116: arch/riscv/kernel/asm-offsets.s] Error 1
   make[3]: Target 'prepare' not remade because of errors.
   make[2]: *** [Makefile:1275: prepare0] Error 2
   make[2]: Target 'prepare' not remade because of errors.
   make[1]: *** [Makefile:234: __sub-make] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [Makefile:234: __sub-make] Error 2
   make: Target 'prepare' not remade because of errors.


vim +17 arch/riscv/include/asm/cacheinfo.h

087958a17658dc Yash Shah 2020-02-20  15  
087958a17658dc Yash Shah 2020-02-20  16  void riscv_set_cacheinfo_ops(struct riscv_cacheinfo_ops *ops);
38f5bd23deae24 Zong Li   2020-08-31 @17  uintptr_t get_cache_size(u32 level, enum cache_type type);
38f5bd23deae24 Zong Li   2020-08-31  18  uintptr_t get_cache_geometry(u32 level, enum cache_type type);
087958a17658dc Yash Shah 2020-02-20  19  

:::::: The code at line 17 was first introduced by commit
:::::: 38f5bd23deae24c8fa67a2c574b6d43df27a8aa8 riscv: Add cache information in AUX vector

:::::: TO: Zong Li <zong.li@sifive.com>
:::::: CC: Palmer Dabbelt <palmerdabbelt@google.com>

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
