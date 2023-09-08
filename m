Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A377EEEB56F
	for <linux-ia64@archiver.kernel.org>; Fri,  8 Sep 2023 20:35:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231203AbjIHUff (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Fri, 8 Sep 2023 16:35:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41848 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232256AbjIHUfe (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Fri, 8 Sep 2023 16:35:34 -0400
Received: from mgamail.intel.com (mgamail.intel.com [134.134.136.65])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DAD8B9C
        for <linux-ia64@vger.kernel.org>; Fri,  8 Sep 2023 13:35:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1694205330; x=1725741330;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=vLs4ovqLgPDQZTWOuUcZtRYlMDIzpxU5Z3TIdNTNres=;
  b=GGqCQtighPkQRP0sZJPhkwyjph3yZz2d9CTTUD+22rHuEhLfGFy2OebK
   HR6lS8aSjSkX11NEkpPJ7K4LWOVnS70ymAs7RLkv+ap6MLHSge7otWw/F
   L7hUcKQl0pH3LJiK0xJsPE2mshbwygoRP8aP8bcS38WBOACd8OcETuB3g
   78/4/onC4ao1740ITV1/DWyvgHKC0VTYYlZHGt2Cz/9xa+8JnufzMk8oV
   jl4mJcYnbcGnTdBllbVjMEiUsa26GJ1oP/ttOzNggd2Ovqguf1NkYHknM
   iPxJis9CIIV5G0Dw3aEWhNm20NgFt0N016n5km0ZtFQNoMJE9BqvyehAA
   w==;
X-IronPort-AV: E=McAfee;i="6600,9927,10827"; a="381563063"
X-IronPort-AV: E=Sophos;i="6.02,237,1688454000"; 
   d="scan'208";a="381563063"
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga103.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 08 Sep 2023 13:35:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10827"; a="745733376"
X-IronPort-AV: E=Sophos;i="6.02,237,1688454000"; 
   d="scan'208";a="745733376"
Received: from lkp-server01.sh.intel.com (HELO 59b3c6e06877) ([10.239.97.150])
  by fmsmga007.fm.intel.com with ESMTP; 08 Sep 2023 13:35:29 -0700
Received: from kbuild by 59b3c6e06877 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qeiCM-0002ac-2y;
        Fri, 08 Sep 2023 20:35:26 +0000
Date:   Sat, 9 Sep 2023 04:34:41 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65 2/4] fs/resctrl2/arch/x86/rdt_l3_cat.c:571:32:
 warning: 'cat_feature' defined but not used
Message-ID: <202309090453.79L6LZbv-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65
head:   13c888afbee9f7da0a4a969617dea9889da9d711
commit: 48b1b4708de24b0c1dff810db00317c3fdcf7bab [2/4] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
config: i386-randconfig-054-20230909 (https://download.01.org/0day-ci/archive/20230909/202309090453.79L6LZbv-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20230909/202309090453.79L6LZbv-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202309090453.79L6LZbv-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> fs/resctrl2/arch/x86/rdt_l3_cat.c:571:32: warning: 'cat_feature' defined but not used [-Wunused-const-variable=]
     571 | static const struct x86_cpu_id cat_feature[] = {
         |                                ^~~~~~~~~~~
--
>> fs/resctrl2/arch/x86/rdt_mbm_local_rate.c:55:32: warning: 'mon_feature' defined but not used [-Wunused-const-variable=]
      55 | static const struct x86_cpu_id mon_feature[] = {
         |                                ^~~~~~~~~~~
--
>> fs/resctrl2/arch/x86/rdt_l3_mba.c:247:32: warning: 'mba_feature' defined but not used [-Wunused-const-variable=]
     247 | static const struct x86_cpu_id mba_feature[] = {
         |                                ^~~~~~~~~~~


vim +/cat_feature +571 fs/resctrl2/arch/x86/rdt_l3_cat.c

   569	
   570	#if !defined(CDP) && !defined(PSEUDO_LOCK)
 > 571	static const struct x86_cpu_id cat_feature[] = {
   572	#if CACHE_LEVEL == 3
   573		X86_MATCH_FEATURE(X86_FEATURE_CAT_L3, 0),
   574	#endif
   575	#if CACHE_LEVEL == 2
   576		X86_MATCH_FEATURE(X86_FEATURE_CAT_L2, 0),
   577	#endif
   578		{ }
   579	};
   580	MODULE_DEVICE_TABLE(x86cpu, cat_feature);
   581	#endif
   582	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
