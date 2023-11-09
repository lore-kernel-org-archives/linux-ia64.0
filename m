Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A28AC4332F
	for <linux-ia64@archiver.kernel.org>; Thu,  9 Nov 2023 17:21:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232316AbjKIRVV (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 9 Nov 2023 12:21:21 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46414 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232252AbjKIRVU (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 9 Nov 2023 12:21:20 -0500
Received: from mgamail.intel.com (mgamail.intel.com [134.134.136.65])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9BC5330F7
        for <linux-ia64@vger.kernel.org>; Thu,  9 Nov 2023 09:21:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1699550478; x=1731086478;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=WMwn/Vym2og5mrMvi2S9kt800BD1g5MXR73BO15EsdE=;
  b=ANUuwfOcqqsYA9n0hFR3KqW1kmCGBD9gLk0BJCEQrQw11Hgt+g8WF76+
   hg4UozFDZdalHnvAKH762q9Ag5FmmDIpq75HyffKM3mpgU8j7sJ6endLz
   TyceXo4V3Y5EurBvZ+Vg5gy9Zh5m7N1PVZPy9nremL92HNzHbKM5iTUbP
   MdAUoNbYgJw7eJAgwkPRlUv5PymxtwxWINJ8ipbY38rHsrok/niK/kr5g
   sES0L9/0WwrkQKjuh+zdLVgfXkIWdumwyU3bMXGY9BzZ4wbx6PWYbqRa/
   GYtfP6FDK/RfvXzEJb5KWtO+Ye0iYr47mVvtGW7tT+LPVdnrwgHLlDb+7
   g==;
X-IronPort-AV: E=McAfee;i="6600,9927,10889"; a="393941559"
X-IronPort-AV: E=Sophos;i="6.03,289,1694761200"; 
   d="scan'208";a="393941559"
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga103.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 09 Nov 2023 09:21:16 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10889"; a="854135336"
X-IronPort-AV: E=Sophos;i="6.03,289,1694761200"; 
   d="scan'208";a="854135336"
Received: from lkp-server01.sh.intel.com (HELO 17d9e85e5079) ([10.239.97.150])
  by FMSMGA003.fm.intel.com with ESMTP; 09 Nov 2023 09:21:14 -0800
Received: from kbuild by 17d9e85e5079 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1r18iO-0008xS-0y;
        Thu, 09 Nov 2023 17:21:12 +0000
Date:   Fri, 10 Nov 2023 01:09:27 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_patches 9/52] fs/resctrl2/kernfs.c:6:19: sparse:
 sparse: symbol 'resctrl_file_ops' was not declared. Should it be static?
Message-ID: <202311092324.LZXnUp3D-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_patches
head:   a6866c2d6be6dd4997cd46120e288fe0b5e16c9b
commit: eca79ecf33e9c18bcfe7c9c39f2cad22092057ab [9/52] resctrl2: Modules can add file(s) in their info/ directory
config: i386-randconfig-062-20230922 (https://download.01.org/0day-ci/archive/20231109/202311092324.LZXnUp3D-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20231109/202311092324.LZXnUp3D-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202311092324.LZXnUp3D-lkp@intel.com/

sparse warnings: (new ones prefixed by >>)
>> fs/resctrl2/kernfs.c:6:19: sparse: sparse: symbol 'resctrl_file_ops' was not declared. Should it be static?

vim +/resctrl_file_ops +6 fs/resctrl2/kernfs.c

     5	
   > 6	struct kernfs_ops resctrl_file_ops = {
     7		.atomic_write_len	= PAGE_SIZE,
     8	};
     9	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
