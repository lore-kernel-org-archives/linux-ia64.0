Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54A63EEB56E
	for <linux-ia64@archiver.kernel.org>; Fri,  8 Sep 2023 22:44:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1343605AbjIHWok (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Fri, 8 Sep 2023 18:44:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44942 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234095AbjIHWok (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Fri, 8 Sep 2023 18:44:40 -0400
Received: from mgamail.intel.com (mgamail.intel.com [192.55.52.93])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 93D9F1FE8
        for <linux-ia64@vger.kernel.org>; Fri,  8 Sep 2023 15:44:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1694213075; x=1725749075;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=RfFfouDR9DIFIbpviqe8GZ7l2dPoFwBdhBuUV1D6kUY=;
  b=ZSvuM7G/r4VOBvLetj2Z6yAa4F8YjRbnl0A1e+T6KJEIjs1NZTSBK54M
   REbeBPYV5Q02r6cIxEZmQpQuRAlkhx3FJEh7RgTSWHBPVaP5m6e7o6W/6
   4KFll+To/ptEjYVfBUH5skg+kBJnkJntYyXPZgsY5I1ldBtnlgvfUO7Tk
   6oYt2EltfLSH1SV6dd/DyCwxO9k2qY2ZEf1/tR3p9OVvpfGUnkNRESqc4
   anIndnWPX8zJQSoRoFzBeb5i5tAMbtgvRjIcXayF1sWc5UDjUANF80z/g
   ICRtAFivQ6YHcLS08yunqgSQmpRwm9zROqCFy1qAvPQtDpAEkAXXgqWDz
   g==;
X-IronPort-AV: E=McAfee;i="6600,9927,10827"; a="375137688"
X-IronPort-AV: E=Sophos;i="6.02,238,1688454000"; 
   d="scan'208";a="375137688"
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 08 Sep 2023 15:44:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10827"; a="989425059"
X-IronPort-AV: E=Sophos;i="6.02,238,1688454000"; 
   d="scan'208";a="989425059"
Received: from lkp-server01.sh.intel.com (HELO 59b3c6e06877) ([10.239.97.150])
  by fmsmga006.fm.intel.com with ESMTP; 08 Sep 2023 15:44:33 -0700
Received: from kbuild by 59b3c6e06877 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qekDH-0002gh-2D;
        Fri, 08 Sep 2023 22:44:31 +0000
Date:   Sat, 9 Sep 2023 06:43:56 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65 4/4] fs/resctrl2/arch/x86/amd_mbec.c:189:32:
 warning: 'bmec_feature' defined but not used
Message-ID: <202309090610.Z43gD7TB-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65
head:   13c888afbee9f7da0a4a969617dea9889da9d711
commit: 13c888afbee9f7da0a4a969617dea9889da9d711 [4/4] resctrl2: AMD Bandwidth Monitoring Event Configuration
config: i386-randconfig-051-20230909 (https://download.01.org/0day-ci/archive/20230909/202309090610.Z43gD7TB-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20230909/202309090610.Z43gD7TB-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202309090610.Z43gD7TB-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> fs/resctrl2/arch/x86/amd_mbec.c:189:32: warning: 'bmec_feature' defined but not used [-Wunused-const-variable=]
     189 | static const struct x86_cpu_id bmec_feature[] = {
         |                                ^~~~~~~~~~~~


vim +/bmec_feature +189 fs/resctrl2/arch/x86/amd_mbec.c

   188	
 > 189	static const struct x86_cpu_id bmec_feature[] = {
   190		X86_MATCH_FEATURE(X86_FEATURE_BMEC, 0),
   191		{ }
   192	};
   193	MODULE_DEVICE_TABLE(x86cpu, bmec_feature);
   194	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
