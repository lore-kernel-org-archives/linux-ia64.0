Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A8B5EB64DC
	for <linux-ia64@archiver.kernel.org>; Mon,  3 Jul 2023 04:09:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229564AbjGCEJG (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Mon, 3 Jul 2023 00:09:06 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41190 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229648AbjGCEJD (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Mon, 3 Jul 2023 00:09:03 -0400
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3CD7F188
        for <linux-ia64@vger.kernel.org>; Sun,  2 Jul 2023 21:09:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1688357342; x=1719893342;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=dPhEmEb4DroScJxjEMffQQw64xsnfPFHnbXq0X8GLr0=;
  b=Q48oUdDipXr7e2B5bY8OswVC7nQRHr2lRCaadGE6cqRb8OreVwTYahu2
   WwcgfMp9zp3mBqvjOErtNUB40xzI70Sz1QsSaT5SgY0RKo5Sd81WEbQxJ
   8LOhFbvtnqRwx8i76O14MxUmeqAOhzCU1Aa6izJJ4Xz/qeRY6BwriB31o
   piL22uz1Kj1U/tduz2ZvDJFism3wEpysd8KRhnW26llY4EhFx/B8ugauZ
   EBTEkG7RGfQ/5Dl+BTyxCjvwjKnKjYQGNVt1h52+BZ0YTZC2fYzGYE6FU
   yGAeP19XYw/cWcTbPXOyG+zxAacOgPmg8q4TvRl/apot4+jltlQzh5DQn
   g==;
X-IronPort-AV: E=McAfee;i="6600,9927,10759"; a="360261779"
X-IronPort-AV: E=Sophos;i="6.01,177,1684825200"; 
   d="scan'208";a="360261779"
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Jul 2023 21:09:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10759"; a="753611499"
X-IronPort-AV: E=Sophos;i="6.01,177,1684825200"; 
   d="scan'208";a="753611499"
Received: from lkp-server01.sh.intel.com (HELO 783282924a45) ([10.239.97.150])
  by orsmga001.jf.intel.com with ESMTP; 02 Jul 2023 21:09:00 -0700
Received: from kbuild by 783282924a45 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qGArz-000H6b-18;
        Mon, 03 Jul 2023 04:08:59 +0000
Date:   Mon, 3 Jul 2023 12:08:57 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v64 2/3] arch/x86/include/asm/resctrl.h:114:45:
 error: invalid use of undefined type 'struct resctrl_group'
Message-ID: <202307031209.IWXDQGr5-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v64
head:   afb7cdd4d64023650b5cc6e003b1aa3d2ab80af1
commit: eda3e6a0e3b6c896d9ced0e8488c06cd373abd2e [2/3] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
config: i386-randconfig-i062-20230703 (https://download.01.org/0day-ci/archive/20230703/202307031209.IWXDQGr5-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce: (https://download.01.org/0day-ci/archive/20230703/202307031209.IWXDQGr5-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202307031209.IWXDQGr5-lkp@intel.com/

All error/warnings (new ones prefixed by >>):

   In file included from arch/x86/kernel/process_32.c:55:
>> arch/x86/include/asm/resctrl.h:101:36: warning: 'struct resctrl_group' declared inside parameter list will not be visible outside of this definition or declaration
     101 | bool arch_alloc_resctrl_ids(struct resctrl_group *rg);
         |                                    ^~~~~~~~~~~~~
   arch/x86/include/asm/resctrl.h:102:35: warning: 'struct resctrl_group' declared inside parameter list will not be visible outside of this definition or declaration
     102 | void arch_free_resctrl_ids(struct resctrl_group *rg);
         |                                   ^~~~~~~~~~~~~
   arch/x86/include/asm/resctrl.h:112:66: warning: 'struct resctrl_group' declared inside parameter list will not be visible outside of this definition or declaration
     112 | static inline bool is_closid_match(struct task_struct *t, struct resctrl_group *rg)
         |                                                                  ^~~~~~~~~~~~~
   arch/x86/include/asm/resctrl.h: In function 'is_closid_match':
>> arch/x86/include/asm/resctrl.h:114:45: error: invalid use of undefined type 'struct resctrl_group'
     114 |         return (t->resctrl_ids >> 32) == (rg->resctrl_ids >> 32);
         |                                             ^~
   arch/x86/include/asm/resctrl.h: At top level:
   arch/x86/include/asm/resctrl.h:117:75: warning: 'struct resctrl_group' declared inside parameter list will not be visible outside of this definition or declaration
     117 | static inline bool arch_is_resctrl_id_match(struct task_struct *t, struct resctrl_group *rg)
         |                                                                           ^~~~~~~~~~~~~
   arch/x86/include/asm/resctrl.h: In function 'arch_is_resctrl_id_match':
   arch/x86/include/asm/resctrl.h:119:15: error: invalid use of undefined type 'struct resctrl_group'
     119 |         if (rg->type == DIR_MON)
         |               ^~
>> arch/x86/include/asm/resctrl.h:119:25: error: 'DIR_MON' undeclared (first use in this function)
     119 |         if (rg->type == DIR_MON)
         |                         ^~~~~~~
   arch/x86/include/asm/resctrl.h:119:25: note: each undeclared identifier is reported only once for each function it appears in
   arch/x86/include/asm/resctrl.h:120:44: error: invalid use of undefined type 'struct resctrl_group'
     120 |                 return t->resctrl_ids == rg->resctrl_ids;
         |                                            ^~
>> arch/x86/include/asm/resctrl.h:121:35: error: passing argument 2 of 'is_closid_match' from incompatible pointer type [-Werror=incompatible-pointer-types]
     121 |         return is_closid_match(t, rg);
         |                                   ^~
         |                                   |
         |                                   struct resctrl_group *
   arch/x86/include/asm/resctrl.h:112:81: note: expected 'struct resctrl_group *' but argument is of type 'struct resctrl_group *'
     112 | static inline bool is_closid_match(struct task_struct *t, struct resctrl_group *rg)
         |                                                           ~~~~~~~~~~~~~~~~~~~~~~^~
   arch/x86/include/asm/resctrl.h: At top level:
   arch/x86/include/asm/resctrl.h:124:68: warning: 'struct resctrl_group' declared inside parameter list will not be visible outside of this definition or declaration
     124 | static inline bool arch_set_task_ids(struct task_struct *t, struct resctrl_group *rg)
         |                                                                    ^~~~~~~~~~~~~
   arch/x86/include/asm/resctrl.h: In function 'arch_set_task_ids':
   arch/x86/include/asm/resctrl.h:126:15: error: invalid use of undefined type 'struct resctrl_group'
     126 |         if (rg->type == DIR_MON) {
         |               ^~
   arch/x86/include/asm/resctrl.h:126:25: error: 'DIR_MON' undeclared (first use in this function)
     126 |         if (rg->type == DIR_MON) {
         |                         ^~~~~~~
   arch/x86/include/asm/resctrl.h:127:41: error: passing argument 2 of 'is_closid_match' from incompatible pointer type [-Werror=incompatible-pointer-types]
     127 |                 if (!is_closid_match(t, rg)) {
         |                                         ^~
         |                                         |
         |                                         struct resctrl_group *
   arch/x86/include/asm/resctrl.h:112:81: note: expected 'struct resctrl_group *' but argument is of type 'struct resctrl_group *'
     112 | static inline bool is_closid_match(struct task_struct *t, struct resctrl_group *rg)
         |                                                           ~~~~~~~~~~~~~~~~~~~~~~^~
   In file included from ./arch/x86/include/generated/asm/rwonce.h:1,
                    from include/linux/compiler.h:246,
                    from include/linux/dev_printk.h:14,
                    from include/linux/device.h:15,
                    from include/linux/node.h:18,
                    from include/linux/cpu.h:17,
                    from arch/x86/kernel/process_32.c:12:
   arch/x86/include/asm/resctrl.h:133:38: error: invalid use of undefined type 'struct resctrl_group'
     133 |         WRITE_ONCE(t->resctrl_ids, rg->resctrl_ids);
         |                                      ^~
   include/asm-generic/rwonce.h:55:40: note: in definition of macro '__WRITE_ONCE'
      55 |         *(volatile typeof(x) *)&(x) = (val);                            \
         |                                        ^~~
   arch/x86/include/asm/resctrl.h:133:9: note: in expansion of macro 'WRITE_ONCE'
     133 |         WRITE_ONCE(t->resctrl_ids, rg->resctrl_ids);
         |         ^~~~~~~~~~
   cc1: some warnings being treated as errors
--
>> fs/resctrl2/arch/x86/alloc.c:55:6: warning: no previous prototype for 'closid_free' [-Wmissing-prototypes]
      55 | void closid_free(int closid)
         |      ^~~~~~~~~~~
--
   fs/resctrl2/arch/x86/rdt_monitor.c: In function 'rdt_rmid_read':
>> fs/resctrl2/arch/x86/rdt_monitor.c:304:26: warning: variable 'm' set but not used [-Wunused-but-set-variable]
     304 |         struct mydomain *m;
         |                          ^


vim +114 arch/x86/include/asm/resctrl.h

   100	
 > 101	bool arch_alloc_resctrl_ids(struct resctrl_group *rg);
   102	void arch_free_resctrl_ids(struct resctrl_group *rg);
   103	bool arch_init_alloc_ids(struct resctrl_resource *r);
   104	int rmid_alloc(int prmid);
   105	void rmid_free(int rmid);
   106	void arch_add_monitor(int mon_event);
   107	void arch_del_monitor(int mon_event);
   108	u64 rdt_rmid_read(int domain_id, int rmid, int event);
   109	void rdt_mbm_apply_quirk(int num_rmids);
   110	u64 get_corrected_mbm_count(u32 rmid, unsigned long val);
   111	
   112	static inline bool is_closid_match(struct task_struct *t, struct resctrl_group *rg)
   113	{
 > 114		return (t->resctrl_ids >> 32) == (rg->resctrl_ids >> 32);
   115	}
   116	
   117	static inline bool arch_is_resctrl_id_match(struct task_struct *t, struct resctrl_group *rg)
   118	{
 > 119		if (rg->type == DIR_MON)
   120			return t->resctrl_ids == rg->resctrl_ids;
 > 121		return is_closid_match(t, rg);
   122	}
   123	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
