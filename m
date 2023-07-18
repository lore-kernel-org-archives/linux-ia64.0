Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD565EB64DA
	for <linux-ia64@archiver.kernel.org>; Tue, 18 Jul 2023 04:56:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229674AbjGRE4i (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 18 Jul 2023 00:56:38 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58478 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229449AbjGRE4h (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 18 Jul 2023 00:56:37 -0400
Received: from mga03.intel.com (mga03.intel.com [134.134.136.65])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6AC72BB
        for <linux-ia64@vger.kernel.org>; Mon, 17 Jul 2023 21:56:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1689656196; x=1721192196;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=+W9C150D2zV4KHuRyfVwC5PHtFHDuNTDzOXOX/YCduE=;
  b=D4XBnKJql4I7d20NMVt8At80rY4+5+qtuCLHnX4OIh/eDofl3qb6DoKA
   XZhQuhTNl/3IWf3PSLHgtX+FfPYd9o4l8k+IiHn8wO3/+Evpglx2Al3lO
   0DkB+eKbkQIyMLlpHN1SP8DB3foCgMi/2mwxpZsaIZninSj/xWLLn0nqh
   ZoZK8H9UHT7yPIjGn97f68Rsi1M2GGFSx/Il+KNiXqMgGK6f4sn015RBw
   B9SA+Fl2pg7kNKkud2bnkRWSv0XGKFb0KFwuYrbyk8EIv38tG2EK99IUY
   kUGCD/DDJ0040rKD3cHGBwA7PB3ecZwZhYIelaTApIC/zFKtnmO2bx6sK
   w==;
X-IronPort-AV: E=McAfee;i="6600,9927,10774"; a="369661307"
X-IronPort-AV: E=Sophos;i="6.01,213,1684825200"; 
   d="scan'208";a="369661307"
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga103.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 17 Jul 2023 21:56:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.01,202,1684825200"; 
   d="scan'208";a="866933804"
Received: from lkp-server02.sh.intel.com (HELO 36946fcf73d7) ([10.239.97.151])
  by fmsmga001.fm.intel.com with ESMTP; 17 Jul 2023 21:56:35 -0700
Received: from kbuild by 36946fcf73d7 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qLclF-0000E1-1t;
        Tue, 18 Jul 2023 04:56:33 +0000
Date:   Tue, 18 Jul 2023 12:55:43 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65rc1 11/11]
 fs/resctrl2/arch/x86/rdt_l2_cdp.c:85:13: warning: variable 'cache_level' set
 but not used
Message-ID: <202307181221.bYTu62iK-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65rc1
head:   16f9fb3b3a3875cdb7f611d60e5072ed15feec27
commit: 16f9fb3b3a3875cdb7f611d60e5072ed15feec27 [11/11] resctrl2: Fix name collision on get_cache_size()
config: i386-randconfig-r006-20230718 (https://download.01.org/0day-ci/archive/20230718/202307181221.bYTu62iK-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce: (https://download.01.org/0day-ci/archive/20230718/202307181221.bYTu62iK-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202307181221.bYTu62iK-lkp@intel.com/

All warnings (new ones prefixed by >>):

   fs/resctrl2/arch/x86/rdt_l2_cdp.c: In function 'get_cache_slice_size':
>> fs/resctrl2/arch/x86/rdt_l2_cdp.c:85:13: warning: variable 'cache_level' set but not used [-Wunused-but-set-variable]
      85 |         int cache_level;
         |             ^~~~~~~~~~~
--
   fs/resctrl2/arch/x86/rdt_l3_cdp.c: In function 'get_cache_slice_size':
>> fs/resctrl2/arch/x86/rdt_l3_cdp.c:85:13: warning: variable 'cache_level' set but not used [-Wunused-but-set-variable]
      85 |         int cache_level;
         |             ^~~~~~~~~~~
--
   fs/resctrl2/arch/x86/rdt_l3_cat.c: In function 'get_cache_slice_size':
>> fs/resctrl2/arch/x86/rdt_l3_cat.c:85:13: warning: variable 'cache_level' set but not used [-Wunused-but-set-variable]
      85 |         int cache_level;
         |             ^~~~~~~~~~~
--
   fs/resctrl2/arch/x86/rdt_l2_cat.c: In function 'get_cache_slice_size':
>> fs/resctrl2/arch/x86/rdt_l2_cat.c:85:13: warning: variable 'cache_level' set but not used [-Wunused-but-set-variable]
      85 |         int cache_level;
         |             ^~~~~~~~~~~


vim +/cache_level +85 fs/resctrl2/arch/x86/rdt_l2_cdp.c

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
