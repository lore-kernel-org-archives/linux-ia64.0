Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.9])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 509951667FA
	for <linux-ia64@vger.kernel.org>; Sat,  8 Jun 2024 04:57:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.9
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717822634; cv=none; b=fNnaPM+hkBDQ5VNvn3lt+WjIIYKuk1sZcPqdiay0v2PSdI/SI78B/nN+Nmz/JiSxN/c6L5VGW+hBn1KDznUtduxCulqkvK2yDk8UtIsg8pjCeDY238Dk7tzHXapVM/DqyqUNlWx2dOeyTxHXtkEEUoq2UWvRtmF0wyGbs9WYj54=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717822634; c=relaxed/simple;
	bh=4mXhgcby4QJyQYvjz0ooyRFwMPxU736tAMECixop3pI=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=Z/IMP2rgVTdlNQAbkOMVPRbmJ3yHOlWliKTVfF6L9BTkpmeTS8vVxCI2ckCid5gYLqcrbJCjE5BJoYGbpozKCN4DPKKPJ25b1V9lZjUEvXaOdySWFgtJaBajNWmlM3lartMTSrJaxa8rENq/+qAeu0TiyiuItAq9lUjcJG4qx/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=Uxxoz2zk; arc=none smtp.client-ip=192.198.163.9
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="Uxxoz2zk"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1717822631; x=1749358631;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=4mXhgcby4QJyQYvjz0ooyRFwMPxU736tAMECixop3pI=;
  b=Uxxoz2zkuTwtAOtRNXkJVXTQOvma7qduycB0ZgV6IZ7J2DQlxQpJmz4p
   GK+raDdcTS8yq35Df7pskTCUIFzjRtmZhj4korhExKTzQuhPhQottsylC
   or4gED/ej6vj6pvWHMfMdy9GRLD6Qc928bkwcT2xwbgtDuboTZsUy4Dgy
   /eupQdxGcoyD9XMrR8MITD3psZ9U99xsZBSgCNttmdZo/IIQPdfHXyuCB
   LllGxlAEZoSIAQXXkGAdu1FCBEH0Z4pcUea8lUnv2MunSNqO/gDRWiL04
   eRx+XTHe7n+pmduS/ZXughUyrIx+rHLhJKwdLutNuPR9yggW5fElmPqqe
   Q==;
X-CSE-ConnectionGUID: gLP8Vb7TT/+xITnoZ1cWbA==
X-CSE-MsgGUID: kG66EPgLS5iFxJlliuCrdw==
X-IronPort-AV: E=McAfee;i="6600,9927,11096"; a="25211586"
X-IronPort-AV: E=Sophos;i="6.08,222,1712646000"; 
   d="scan'208";a="25211586"
Received: from fmviesa009.fm.intel.com ([10.60.135.149])
  by fmvoesa103.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 07 Jun 2024 21:57:09 -0700
X-CSE-ConnectionGUID: YQ0YKM5yS86iXAtS2D1dVQ==
X-CSE-MsgGUID: AKWAgStQSeSiDDjGCJ/DRw==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.08,222,1712646000"; 
   d="scan'208";a="38651184"
Received: from lkp-server01.sh.intel.com (HELO 472b94a103a1) ([10.239.97.150])
  by fmviesa009.fm.intel.com with ESMTP; 07 Jun 2024 21:57:08 -0700
Received: from kbuild by 472b94a103a1 with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1sFo8Y-000122-0M;
	Sat, 08 Jun 2024 04:57:06 +0000
Date: Sat, 8 Jun 2024 12:56:18 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>
Subject: [aegl:get_cpu_cacheinfo_level 2/3] include/linux/cpuhplock.h:39:58:
 error: use of undeclared identifier 'EPERM'
Message-ID: <202406081215.5IP0JQSs-lkp@intel.com>
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
config: x86_64-randconfig-104-20240608 (https://download.01.org/0day-ci/archive/20240608/202406081215.5IP0JQSs-lkp@intel.com/config)
compiler: clang version 18.1.5 (https://github.com/llvm/llvm-project 617a15a9eac96088ae5e9134248d8236e34b91b1)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20240608/202406081215.5IP0JQSs-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202406081215.5IP0JQSs-lkp@intel.com/

All errors (new ones prefixed by >>):

   In file included from arch/x86/kernel/cpu/resctrl/rdtgroup.c:15:
   In file included from include/linux/cacheinfo.h:6:
>> include/linux/cpuhplock.h:39:58: error: use of undeclared identifier 'EPERM'
      39 | static inline int remove_cpu(unsigned int cpu) { return -EPERM; }
         |                                                          ^
   In file included from arch/x86/kernel/cpu/resctrl/rdtgroup.c:16:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:98:11: warning: array index 3 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
      98 |                 return (set->sig[3] | set->sig[2] |
         |                         ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/rdtgroup.c:16:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:98:25: warning: array index 2 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
      98 |                 return (set->sig[3] | set->sig[2] |
         |                                       ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/rdtgroup.c:16:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:99:4: warning: array index 1 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
      99 |                         set->sig[1] | set->sig[0]) == 0;
         |                         ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/rdtgroup.c:16:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:101:11: warning: array index 1 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
     101 |                 return (set->sig[1] | set->sig[0]) == 0;
         |                         ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/rdtgroup.c:16:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:114:11: warning: array index 3 is past the end of the array (that has type 'const unsigned long[1]') [-Warray-bounds]
     114 |                 return  (set1->sig[3] == set2->sig[3]) &&
         |                          ^         ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
--
   In file included from arch/x86/kernel/cpu/resctrl/pseudo_lock.c:14:
   In file included from include/linux/cacheinfo.h:6:
>> include/linux/cpuhplock.h:39:58: error: use of undeclared identifier 'EPERM'
      39 | static inline int remove_cpu(unsigned int cpu) { return -EPERM; }
         |                                                          ^
   In file included from arch/x86/kernel/cpu/resctrl/pseudo_lock.c:15:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:98:11: warning: array index 3 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
      98 |                 return (set->sig[3] | set->sig[2] |
         |                         ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/pseudo_lock.c:15:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:98:25: warning: array index 2 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
      98 |                 return (set->sig[3] | set->sig[2] |
         |                                       ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/pseudo_lock.c:15:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:99:4: warning: array index 1 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
      99 |                         set->sig[1] | set->sig[0]) == 0;
         |                         ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/pseudo_lock.c:15:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:101:11: warning: array index 1 is past the end of the array (that has type 'unsigned long[1]') [-Warray-bounds]
     101 |                 return (set->sig[1] | set->sig[0]) == 0;
         |                         ^        ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here
      24 |         unsigned long sig[_NSIG_WORDS];
         |         ^
   In file included from arch/x86/kernel/cpu/resctrl/pseudo_lock.c:15:
   In file included from include/linux/cpu.h:17:
   In file included from include/linux/node.h:18:
   In file included from include/linux/device.h:32:
   In file included from include/linux/device/driver.h:21:
   In file included from include/linux/module.h:19:
   In file included from include/linux/elf.h:6:
   In file included from arch/x86/include/asm/elf.h:10:
   In file included from arch/x86/include/asm/ia32.h:7:
   In file included from include/linux/compat.h:17:
   In file included from include/linux/fs.h:33:
   In file included from include/linux/percpu-rwsem.h:7:
   In file included from include/linux/rcuwait.h:6:
   In file included from include/linux/sched/signal.h:6:
   include/linux/signal.h:114:11: warning: array index 3 is past the end of the array (that has type 'const unsigned long[1]') [-Warray-bounds]
     114 |                 return  (set1->sig[3] == set2->sig[3]) &&
         |                          ^         ~
   arch/x86/include/asm/signal.h:24:2: note: array 'sig' declared here


vim +/EPERM +39 include/linux/cpuhplock.h

c0bea3bea7eb170 Tony Luck 2024-06-07  30  
c0bea3bea7eb170 Tony Luck 2024-06-07  31  static inline void cpus_write_lock(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  32  static inline void cpus_write_unlock(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  33  static inline void cpus_read_lock(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  34  static inline void cpus_read_unlock(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  35  static inline int  cpus_read_trylock(void) { return true; }
c0bea3bea7eb170 Tony Luck 2024-06-07  36  static inline void lockdep_assert_cpus_held(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  37  static inline void cpu_hotplug_disable(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  38  static inline void cpu_hotplug_enable(void) { }
c0bea3bea7eb170 Tony Luck 2024-06-07 @39  static inline int remove_cpu(unsigned int cpu) { return -EPERM; }
c0bea3bea7eb170 Tony Luck 2024-06-07  40  static inline void smp_shutdown_nonboot_cpus(unsigned int primary_cpu) { }
c0bea3bea7eb170 Tony Luck 2024-06-07  41  #endif	/* !CONFIG_HOTPLUG_CPU */
c0bea3bea7eb170 Tony Luck 2024-06-07  42  

:::::: The code at line 39 was first introduced by commit
:::::: c0bea3bea7eb1701c38f23c8ae2d0a49fd35cbbd cpu: Move CPU hotplug function declarations into their own header

:::::: TO: Tony Luck <tony.luck@intel.com>
:::::: CC: Tony Luck <tony.luck@intel.com>

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
