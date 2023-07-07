Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2564CEB64D9
	for <linux-ia64@archiver.kernel.org>; Fri,  7 Jul 2023 13:35:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231587AbjGGNfC (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Fri, 7 Jul 2023 09:35:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50498 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229460AbjGGNfB (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Fri, 7 Jul 2023 09:35:01 -0400
Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CD6051BC3
        for <linux-ia64@vger.kernel.org>; Fri,  7 Jul 2023 06:35:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1688736900; x=1720272900;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=817HFIjjnyArV4Z/6I80SjkEN4umNsNHOJg8+STbovY=;
  b=ASDsP73q7StvCsNl9RM8gVQGIigE3zb6wpt+WjpgGNTlz14Yj15waQ7L
   VeTD/G2Pjan1sUkk1wIrdcFDY0gJdhULoA6hSE2fpq/nyxUIITCwwdat4
   RUCyhTXmCFdvKv6jPtXIU1C/YC9lYNXy95NYrnIOUN1+8d3Wt79cVB7x1
   LkmK+Gi/cI8pp22tP56hMvKR2VaUgAg5Nt3L1el+ul1/FERyl5ZPzAAg8
   RlmLlTw/JS9ofXceWUmJ4uXKDppcXpV4KSE1wfpDoKeLPQbbgEMwUng2G
   lfTIrePHK6FKGmx2XH38aO4RWlNQcXmqb/xbG0eYnRB8Kh2yIpHQgr/UI
   A==;
X-IronPort-AV: E=McAfee;i="6600,9927,10764"; a="366471735"
X-IronPort-AV: E=Sophos;i="6.01,187,1684825200"; 
   d="scan'208";a="366471735"
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 07 Jul 2023 06:33:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10764"; a="966656811"
X-IronPort-AV: E=Sophos;i="6.01,187,1684825200"; 
   d="scan'208";a="966656811"
Received: from lkp-server01.sh.intel.com (HELO c544d7fc5005) ([10.239.97.150])
  by fmsmga006.fm.intel.com with ESMTP; 07 Jul 2023 06:33:00 -0700
Received: from kbuild by c544d7fc5005 with local (Exim 4.96)
        (envelope-from <lkp@intel.com>)
        id 1qHlZz-000210-2D;
        Fri, 07 Jul 2023 13:32:59 +0000
Date:   Fri, 7 Jul 2023 21:32:27 +0800
From:   kernel test robot <lkp@intel.com>
To:     Tony Luck <tony.luck@intel.com>
Cc:     oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:resctrl2_v64 5/5] fs/resctrl2/monitor.c:67:6: warning: no
 previous prototype for 'remove_one_file'
Message-ID: <202307072159.um3Qqjt5-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v64
head:   ae4a417f18e2317ad0ffbbf1b2a337277d9cd212
commit: ae4a417f18e2317ad0ffbbf1b2a337277d9cd212 [5/5] resctrl2: CPU hot plug fixes
config: i386-randconfig-i062-20230703 (https://download.01.org/0day-ci/archive/20230707/202307072159.um3Qqjt5-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce: (https://download.01.org/0day-ci/archive/20230707/202307072159.um3Qqjt5-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202307072159.um3Qqjt5-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> fs/resctrl2/monitor.c:67:6: warning: no previous prototype for 'remove_one_file' [-Wmissing-prototypes]
      67 | void remove_one_file(struct resctrl_resource *r, struct resctrl_group *rg, int id,
         |      ^~~~~~~~~~~~~~~

sparse warnings: (new ones prefixed by >>)
>> fs/resctrl2/monitor.c:67:6: sparse: sparse: symbol 'remove_one_file' was not declared. Should it be static?


vim +/remove_one_file +67 fs/resctrl2/monitor.c

    66	
  > 67	void remove_one_file(struct resctrl_resource *r, struct resctrl_group *rg, int id,
    68			     struct list_head *h)
    69	{
    70		struct kernfs_node *parent_kn = rg->mondata;
    71		struct resctrl_node_info *rni;
    72		struct kernfs_node *kn;
    73		char name[20];
    74	
    75		sprintf(name, r->mon_domain_dir, id);
    76		kn = kernfs_find_and_get_ns(parent_kn, name, NULL);
    77		if (!kn)
    78			return;
    79		kn = kernfs_find_and_get_ns(kn, r->mon_domain_file, NULL);
    80		if (!kn)
    81			return;
    82		rni = kn->priv;
    83		atomic_inc(&rni->waitcount);
    84		rni->flags |= RESCTRL_DELETED;
    85		kernfs_remove(kn);
    86		list_add(&rni->clean_list, h);
    87	}
    88	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
