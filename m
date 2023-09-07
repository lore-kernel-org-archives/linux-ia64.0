Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DF62EC875E
	for <linux-ia64@archiver.kernel.org>; Thu,  7 Sep 2023 22:16:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232200AbjIGWQK (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 7 Sep 2023 18:16:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59932 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237664AbjIGWQJ (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 7 Sep 2023 18:16:09 -0400
Received: from mgamail.intel.com (mgamail.intel.com [134.134.136.126])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 51AE11BD5
        for <linux-ia64@vger.kernel.org>; Thu,  7 Sep 2023 15:16:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1694124966; x=1725660966;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=4b4lyxIV/a+GwUu9bLZLE7kHovIKqrEIgLWgm2AvXzw=;
  b=VyWOFx5OGX+EBVRIQlrcIjeaEvKzyBEvaxCgCFWA5z7CWF++C5Odgz7l
   yNtarCegdodYAZXMM4BVb1tFcQnFRoLFIDIhWEsSVDuzF0/kwdblnodvb
   Col/oPAXfVq5s1NTFztygtlWS7o1ViYTU8waTcZFUOVXw1HuyNjek1vce
   QGmrKRyBu7eeH5O9LsKQHwhM8pbUyTQx226oe5x3+80DFBs8eO/tpVRyP
   kSW8I3e84eWEyFbCu8FfIqld8X/2SaF0HjSjieqNrGbS5z+W+5RNqfxxX
   YNufxZjw+bujuNbQMyh7p6L48MJd4MQH78Z/tsYUOCW4k7OAxHO+jDfI2
   A==;
X-IronPort-AV: E=McAfee;i="6600,9927,10826"; a="362553513"
X-IronPort-AV: E=Sophos;i="6.02,236,1688454000"; 
   d="scan'208";a="362553513"
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 07 Sep 2023 15:15:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10826"; a="735693008"
X-IronPort-AV: E=Sophos;i="6.02,236,1688454000"; 
   d="scan'208";a="735693008"
Received: from lkp-server01.sh.intel.com (HELO 59b3c6e06877) ([10.239.97.150])
  by orsmga007.jf.intel.com with ESMTP; 07 Sep 2023 15:15:34 -0700
Received: from kbuild by 59b3c6e06877 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qeNHg-0001dT-1G;
        Thu, 07 Sep 2023 22:15:32 +0000
Date:   Fri, 8 Sep 2023 06:15:03 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
        linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v65 3/4] fs/resctrl2/arch/x86/amd_smba.c:243:32:
 warning: unused variable 'smba_feature'
Message-ID: <202309080600.4w3asiAW-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65
head:   13c888afbee9f7da0a4a969617dea9889da9d711
commit: 75c85a7905a138996d3d1309cc87798db5979de0 [3/4] resctrl2: AMD Slow Memory Bandwidth Allocation
config: x86_64-randconfig-r011-20230908 (https://download.01.org/0day-ci/archive/20230908/202309080600.4w3asiAW-lkp@intel.com/config)
compiler: clang version 16.0.4 (https://github.com/llvm/llvm-project.git ae42196bc493ffe877a7e3dff8be32035dea4d07)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20230908/202309080600.4w3asiAW-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202309080600.4w3asiAW-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> fs/resctrl2/arch/x86/amd_smba.c:243:32: warning: unused variable 'smba_feature' [-Wunused-const-variable]
   static const struct x86_cpu_id smba_feature[] = {
                                  ^
   1 warning generated.


vim +/smba_feature +243 fs/resctrl2/arch/x86/amd_smba.c

   242	
 > 243	static const struct x86_cpu_id smba_feature[] = {
   244		X86_MATCH_FEATURE(X86_FEATURE_SMBA, 0),
   245		{ },
   246	};
   247	MODULE_DEVICE_TABLE(x86cpu, smba_feature);
   248	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
