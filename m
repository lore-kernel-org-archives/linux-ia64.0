Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3F938BF8
	for <linux-ia64@vger.kernel.org>; Sat,  8 Jun 2024 03:19:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.10
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717816748; cv=none; b=mOrIe05K0bw8riebcwYoi0E4PTOz9FV8voQF2WzTNIXvOvLJZKjaYIh69wLZySLD7Fgkxdiyg/YjD/Ve552R2Yoi1S6iLvVquh7CfFNjf/9TZpYzHWtEUi4jPV8C90ttYXk63fZPLvIVQGsNRvEh0TKQ/gjIcG2le/C/q9Y+3I0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717816748; c=relaxed/simple;
	bh=xpMAhnQiTZJG7oZr2EwPnjx9QF5iRv6ISf5vU/K3ruk=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=IHyD/v4wpZqASKPCubXC9St4/60GbXVgnXJAgAsjGB+hfXoROLTLPicbzV5vYaBi9S/yLhztIWov+VdGP4yf5p5dbsVRIv63mqZkW3SBi0mmeS1Wge9H+vU95EUcoaAroVdPUeS5hR7tOgNjuompAsd0GC2Fg9JFtEHSHUdCpNY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=Bgl/+a5u; arc=none smtp.client-ip=192.198.163.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="Bgl/+a5u"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1717816745; x=1749352745;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=xpMAhnQiTZJG7oZr2EwPnjx9QF5iRv6ISf5vU/K3ruk=;
  b=Bgl/+a5uS+MXuC608JmvnmtKKRoJj2/22K1DJdw7EHKBqpedikeSjiYr
   PGAif/Dd643XKGTd98JyPUOfl0ieRZ37GFD6uEvSv39yo+SPRiPFqtGMT
   OR/G9SDlC5/mWFySb27TwZPNwoGOy7GOfThhLgBLEXNbqPqMZnsA5CphV
   T/rui6KsyJuK61D+jrycNlObY/5wlmk1YQIDTQY/45uRXeb2pV1zT3Uqu
   bpLWGfYQF9cwdDS8jDVJyRMqqV0ajiStDVWFB1i73GioN6iDvauvq2GjK
   x/UaUwbfFQ8fmUZ/DjEGwXOudJlgQ0Yc2OchQcJzsZpWF7E4WlF5T+5up
   A==;
X-CSE-ConnectionGUID: zPlKtB0HQl6N6V0VwXTSnw==
X-CSE-MsgGUID: 3X/m678JQfqpfAa5hWEnQg==
X-IronPort-AV: E=McAfee;i="6600,9927,11096"; a="25958543"
X-IronPort-AV: E=Sophos;i="6.08,222,1712646000"; 
   d="scan'208";a="25958543"
Received: from orviesa009.jf.intel.com ([10.64.159.149])
  by fmvoesa104.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 07 Jun 2024 20:19:04 -0700
X-CSE-ConnectionGUID: ge5xRtnwTdaf3hoRiLhVyA==
X-CSE-MsgGUID: Y8Axy22YSDuEunDJuoXG+g==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.08,222,1712646000"; 
   d="scan'208";a="38597317"
Received: from lkp-server01.sh.intel.com (HELO 472b94a103a1) ([10.239.97.150])
  by orviesa009.jf.intel.com with ESMTP; 07 Jun 2024 20:19:02 -0700
Received: from kbuild by 472b94a103a1 with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1sFmbb-0000u6-23;
	Sat, 08 Jun 2024 03:18:59 +0000
Date: Sat, 8 Jun 2024 11:18:24 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>
Subject: [aegl:get_cpu_cacheinfo_level 2/3] include/linux/cpuhplock.h:39:58:
 error: 'EPERM' undeclared
Message-ID: <202406081130.r7jZwCC5-lkp@intel.com>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git get_cpu_cacheinfo_level
head:   1c9e9c336edc795736b7f42999bfed1cfa94724e
commit: 476529e56cba3ab0efd64bca5e40d7e4b8b2085c [2/3] cacheinfo: Add function to get cacheinfo for a given (cpu, cachelevel)
config: x86_64-randconfig-102-20240608 (https://download.01.org/0day-ci/archive/20240608/202406081130.r7jZwCC5-lkp@intel.com/config)
compiler: gcc-13 (Ubuntu 13.2.0-4ubuntu3) 13.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20240608/202406081130.r7jZwCC5-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202406081130.r7jZwCC5-lkp@intel.com/

All errors (new ones prefixed by >>):

   In file included from include/linux/cacheinfo.h:6,
                    from arch/x86/kernel/cpu/resctrl/rdtgroup.c:15:
   include/linux/cpuhplock.h: In function 'remove_cpu':
>> include/linux/cpuhplock.h:39:58: error: 'EPERM' undeclared (first use in this function)
      39 | static inline int remove_cpu(unsigned int cpu) { return -EPERM; }
         |                                                          ^~~~~
   include/linux/cpuhplock.h:39:58: note: each undeclared identifier is reported only once for each function it appears in


vim +/EPERM +39 include/linux/cpuhplock.h

c0bea3bea7eb17 Tony Luck 2024-06-07  30  
c0bea3bea7eb17 Tony Luck 2024-06-07  31  static inline void cpus_write_lock(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  32  static inline void cpus_write_unlock(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  33  static inline void cpus_read_lock(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  34  static inline void cpus_read_unlock(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  35  static inline int  cpus_read_trylock(void) { return true; }
c0bea3bea7eb17 Tony Luck 2024-06-07  36  static inline void lockdep_assert_cpus_held(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  37  static inline void cpu_hotplug_disable(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  38  static inline void cpu_hotplug_enable(void) { }
c0bea3bea7eb17 Tony Luck 2024-06-07 @39  static inline int remove_cpu(unsigned int cpu) { return -EPERM; }
c0bea3bea7eb17 Tony Luck 2024-06-07  40  static inline void smp_shutdown_nonboot_cpus(unsigned int primary_cpu) { }
c0bea3bea7eb17 Tony Luck 2024-06-07  41  #endif	/* !CONFIG_HOTPLUG_CPU */
c0bea3bea7eb17 Tony Luck 2024-06-07  42  

:::::: The code at line 39 was first introduced by commit
:::::: c0bea3bea7eb1701c38f23c8ae2d0a49fd35cbbd cpu: Move CPU hotplug function declarations into their own header

:::::: TO: Tony Luck <tony.luck@intel.com>
:::::: CC: Tony Luck <tony.luck@intel.com>

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
