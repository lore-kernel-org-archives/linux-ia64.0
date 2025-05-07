Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91CB31FECCD
	for <linux-ia64@vger.kernel.org>; Wed,  7 May 2025 06:20:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.8
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746598811; cv=none; b=VvjJsHLobi5pQdbTBJvb9cvTDWlixZd/xxGRWgmEYgtj1aPKYh1h8TftqWM848RlchuoXIpvqSWq++yuFOq4NF6ORdR1prcnT3T0QJhApdbiLYApgF4vT6rnCQq74Cv0xL7eH3XOkdF+a2ZlQvEeecJb3zQ2W2iF7zTkfzqib8c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746598811; c=relaxed/simple;
	bh=KBod6w2C+uCVKmnbu/CU+O4tyEz98R+8UrW4PahykhQ=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=V6NzhG8hhkBVzw8vgWZGimh8AOVVGgKEycfwbDA4Qph8SGUTsRBGNJX+jojF3LYHKS5k4n7weTltkxvhXQVIRxlsn16F6bEls+wRtZGZxioUwrbxbHPHrnNbRxyO35PjOT9u1lWKV0/bW0Bi+1Gl/3Aconp1WtLrHyG0sxutHuI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=f8X1V2HD; arc=none smtp.client-ip=192.198.163.8
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="f8X1V2HD"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1746598810; x=1778134810;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=KBod6w2C+uCVKmnbu/CU+O4tyEz98R+8UrW4PahykhQ=;
  b=f8X1V2HDEypfcmWd/HYF9gf70uBooVg6ZmqAGj18ngj9Rf7tuhpvWdvt
   Jr+3M9FMYCBxWQ/otaA+7cK6p35jEgg1WnEVSKOr41Jqg2uUnclvO+WGV
   Uh5F5UzFCQk9aMO23wFine0vhnFYqUHeTdFaSAyrmBjTRxYtqswOIAJi9
   cu7nUN5BW86hRXWGUK8ZWzuCnlzFuhD+bzbBj/wPRFp91kwCkfOcOQU+U
   VmX+7Oc22Yc+EGAD6cbbE8Unx5VrX6E9DWKNInUF9C0VbqEypkStWSeV0
   /f9H6mRaCFQBQfhmvm6jy8wmFsxEaGqaSBwTAFDNj5TKpS/hGKlIzt+oM
   g==;
X-CSE-ConnectionGUID: VMBn64QiSR29TDVIFJEPWg==
X-CSE-MsgGUID: FCqEJAf9Ra+i9CexVy+j5w==
X-IronPort-AV: E=McAfee;i="6700,10204,11425"; a="65839616"
X-IronPort-AV: E=Sophos;i="6.15,268,1739865600"; 
   d="scan'208";a="65839616"
Received: from fmviesa002.fm.intel.com ([10.60.135.142])
  by fmvoesa102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 06 May 2025 23:20:09 -0700
X-CSE-ConnectionGUID: a1CsT08BQoiV0OMUBsfUNQ==
X-CSE-MsgGUID: 8dLpmHOoQxOUBaCy9yNSTA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.15,268,1739865600"; 
   d="scan'208";a="159146606"
Received: from lkp-server01.sh.intel.com (HELO 1992f890471c) ([10.239.97.150])
  by fmviesa002.fm.intel.com with ESMTP; 06 May 2025 23:20:08 -0700
Received: from kbuild by 1992f890471c with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1uCY8T-0007BR-2S;
	Wed, 07 May 2025 06:20:05 +0000
Date: Wed, 7 May 2025 14:19:56 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:rdt-aet-v4 30/31]
 arch/x86/kernel/cpu/resctrl/intel_aet.c:247:62: sparse: sparse: incorrect
 type in initializer (different address spaces)
Message-ID: <202505071424.rK7gdiBM-lkp@intel.com>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git rdt-aet-v4
head:   fb3c11ab090e476b565e4dfaec4afbc0465b1fc9
commit: ed4a6c1e59de38ca0465251dc3c12207ba629259 [30/31] x86/resctrl: Add info/PERF_PKG_MON/status file
config: x86_64-randconfig-121-20250502 (https://download.01.org/0day-ci/archive/20250507/202505071424.rK7gdiBM-lkp@intel.com/config)
compiler: clang version 20.1.2 (https://github.com/llvm/llvm-project 58df0ef89dd64126512e4ee27b4ac3fd8ddf6247)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20250507/202505071424.rK7gdiBM-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202505071424.rK7gdiBM-lkp@intel.com/

sparse warnings: (new ones prefixed by >>)
>> arch/x86/kernel/cpu/resctrl/intel_aet.c:247:62: sparse: sparse: incorrect type in initializer (different address spaces) @@     expected unsigned long long [usertype] *[noderef] __iomem info @@     got void [noderef] __iomem * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:247:62: sparse:     expected unsigned long long [usertype] *[noderef] __iomem info
   arch/x86/kernel/cpu/resctrl/intel_aet.c:247:62: sparse:     got void [noderef] __iomem *
>> arch/x86/kernel/cpu/resctrl/intel_aet.c:251:31: sparse: sparse: incorrect type in argument 1 (different address spaces) @@     expected void const volatile [noderef] __iomem *addr @@     got unsigned long long [usertype] * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:251:31: sparse:     expected void const volatile [noderef] __iomem *addr
   arch/x86/kernel/cpu/resctrl/intel_aet.c:251:31: sparse:     got unsigned long long [usertype] *
   arch/x86/kernel/cpu/resctrl/intel_aet.c:253:31: sparse: sparse: incorrect type in argument 1 (different address spaces) @@     expected void const volatile [noderef] __iomem *addr @@     got unsigned long long [usertype] * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:253:31: sparse:     expected void const volatile [noderef] __iomem *addr
   arch/x86/kernel/cpu/resctrl/intel_aet.c:253:31: sparse:     got unsigned long long [usertype] *
   arch/x86/kernel/cpu/resctrl/intel_aet.c:255:31: sparse: sparse: incorrect type in argument 1 (different address spaces) @@     expected void const volatile [noderef] __iomem *addr @@     got unsigned long long [usertype] * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:255:31: sparse:     expected void const volatile [noderef] __iomem *addr
   arch/x86/kernel/cpu/resctrl/intel_aet.c:255:31: sparse:     got unsigned long long [usertype] *
>> arch/x86/kernel/cpu/resctrl/intel_aet.c:251:27: sparse: sparse: dereference of noderef expression
>> arch/x86/kernel/cpu/resctrl/intel_aet.c:251:27: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:253:27: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:253:27: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:255:27: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:255:27: sparse: sparse: dereference of noderef expression

vim +247 arch/x86/kernel/cpu/resctrl/intel_aet.c

   244	
   245	static void show_debug(struct seq_file *s, struct event_group *e, int pkg, int instance)
   246	{
 > 247		u64 *info __iomem = e->pkginfo[pkg]->addrs[instance] + e->mmio_size;
   248	
   249		/* Information registers are the last three qwords in MMIO space */
   250		seq_printf(s, "%s %d:%d agg_data_loss_count = %llu\n", e->name, pkg, instance,
 > 251			   readq(&info[-3]));
   252		seq_printf(s, "%s %d:%d agg_data_loss_timestamp = %llu\n", e->name, pkg, instance,
   253			   readq(&info[-2]));
   254		seq_printf(s, "%s %d:%d last_update_timestamp = %llu\n", e->name, pkg, instance,
   255			   readq(&info[-1]));
   256	}
   257	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
