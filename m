Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CC57EC8759
	for <linux-ia64@archiver.kernel.org>; Thu,  7 Sep 2023 20:28:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232815AbjIGU2i (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 7 Sep 2023 16:28:38 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52342 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231590AbjIGU2h (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 7 Sep 2023 16:28:37 -0400
Received: from mgamail.intel.com (mgamail.intel.com [134.134.136.100])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1DFE91703
        for <linux-ia64@vger.kernel.org>; Thu,  7 Sep 2023 13:28:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1694118514; x=1725654514;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=BB+LQdugJZ7GbL9afXRYDqv7rBUtA0qIbYwIhow0bK0=;
  b=G/pUmrbOJK+kGW48w96PaxjeS4SLysCWqoQd1PBxkBTqQlcLS4wAuxBN
   Q0ArHhij5gVV8XpbWF5rbLWDyyydoUADtWW+hGPL845G1LoMnesPHKztp
   FBXtstnND5n1XCRz9/4qNZ39+IlSSkf4quXmMaZIfmhdxl6UyCho0W4r6
   G3XH4IH15bK36dYPbUSm2UYTI+ep0F7jnbcyd2bp0ZubvmL74+ar9UejW
   MwSuHW/d90uvQYw4W8i4kM/gJgfYS6moyBI/3IuHBmYiSbaxeEKdNYhjn
   XAV+S0jSeYts+XAZaBtdKinCXc36vOqgwjIXQpvTjFatOHXzc7JNh0Kza
   Q==;
X-IronPort-AV: E=McAfee;i="6600,9927,10826"; a="443884595"
X-IronPort-AV: E=Sophos;i="6.02,236,1688454000"; 
   d="scan'208";a="443884595"
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga105.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 07 Sep 2023 13:28:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10826"; a="988926604"
X-IronPort-AV: E=Sophos;i="6.02,236,1688454000"; 
   d="scan'208";a="988926604"
Received: from lkp-server01.sh.intel.com (HELO 59b3c6e06877) ([10.239.97.150])
  by fmsmga006.fm.intel.com with ESMTP; 07 Sep 2023 13:28:31 -0700
Received: from kbuild by 59b3c6e06877 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qeLc5-0001Z3-2K;
        Thu, 07 Sep 2023 20:28:29 +0000
Date:   Fri, 8 Sep 2023 04:27:44 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
        linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65 2/4]
 fs/resctrl2/arch/x86/rdt_mbm_local_bytes.c:55:32: warning: unused variable
 'mon_feature'
Message-ID: <202309080444.lKTIXlIS-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65
head:   13c888afbee9f7da0a4a969617dea9889da9d711
commit: 48b1b4708de24b0c1dff810db00317c3fdcf7bab [2/4] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
config: x86_64-randconfig-r011-20230908 (https://download.01.org/0day-ci/archive/20230908/202309080444.lKTIXlIS-lkp@intel.com/config)
compiler: clang version 16.0.4 (https://github.com/llvm/llvm-project.git ae42196bc493ffe877a7e3dff8be32035dea4d07)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20230908/202309080444.lKTIXlIS-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202309080444.lKTIXlIS-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> fs/resctrl2/arch/x86/rdt_mbm_local_bytes.c:55:32: warning: unused variable 'mon_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id mon_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_mbm_total_bytes.c:55:32: warning: unused variable 'mon_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id mon_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_llc_occupancy.c:55:32: warning: unused variable 'mon_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id mon_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_mbm_total_rate.c:55:32: warning: unused variable 'mon_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id mon_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_l3_cat.c:571:32: warning: unused variable 'cat_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id cat_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_l2_cat.c:571:32: warning: unused variable 'cat_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id cat_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_l3_mba.c:247:32: warning: unused variable 'mba_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id mba_feature[] = {
                                  ^
   1 warning generated.
--
>> fs/resctrl2/arch/x86/rdt_mbm_local_rate.c:55:32: warning: unused variable 'mon_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id mon_feature[] = {
                                  ^
   1 warning generated.


vim +/mon_feature +55 fs/resctrl2/arch/x86/rdt_mbm_local_bytes.c

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
