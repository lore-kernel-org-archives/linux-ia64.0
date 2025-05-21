Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 700592356BE
	for <linux-ia64@vger.kernel.org>; Wed, 21 May 2025 07:56:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747814195; cv=none; b=EXZwa++u/sOJ6Wq2EdGpujd1kZiyl+2B3Dems0VVBJ4wZefQgz+YcfqKRse8f3yyQg66eZr9QUDNoHrPb0nmJz0+Y8LDFBm+Je2d0ceFAiB/qonZDZ3QUiScSxEbsZbQ+mSf7qS71E+GDUHhbz/WietfM4qARaM9em807mjeuns=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747814195; c=relaxed/simple;
	bh=80nRHTJWLlNZ/VcWl/U+9b9fQyUYhOYH1kH1PAu1CvE=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=AvafGtku44Z5F7qKRPEj3mOxfVHutk2ssNCZCKMqihgFxkGIu0liNXNXb8rQqGyyVItrQd96foVuzfm86rVFhgb9+bi8dBtPbivqnO1sw46Of4fSUWI8NSNnuf7vhn/hpWvL3hcREVqEQidlbcMNCPHpXViiBxKbMoI79CAoaDQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=WANpHWFW; arc=none smtp.client-ip=192.198.163.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="WANpHWFW"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1747814193; x=1779350193;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=80nRHTJWLlNZ/VcWl/U+9b9fQyUYhOYH1kH1PAu1CvE=;
  b=WANpHWFW6AgGti2UjPIsjmFk0UIz1pN+9+pmkt5yw7UQw50NrppnmUrC
   pWIvhdxzmvSrz3a64XwHMOw3HKX+PmaJees79v4z5gTPXdBGkCMkwKkq/
   L04WJscE5ZXc4v+6Bw5zmtCFb98I7Er6og3Afh1iy4WO5T0F7GtOQYK0+
   Twwd+U5GE+GsWYuhAw7C6DrystB0/lRW4I7kGXMCfEUzCow3TCwOBOPzQ
   9zWEdvLzvmTwF3d+GyzCnPURu8lCJVZOn8P/9eI2ICcz2bFR4z4w5kWW4
   XMVngGY+KandwBqzbPzuhF171z7h8fQWAaXYPuHKP0Cf4XHY+/lG4uK8d
   w==;
X-CSE-ConnectionGUID: IsxEiiA9SOmFW+fgMOC+gg==
X-CSE-MsgGUID: r7B5rIJ8SP+QrpHAxGxz3Q==
X-IronPort-AV: E=McAfee;i="6700,10204,11439"; a="48897921"
X-IronPort-AV: E=Sophos;i="6.15,303,1739865600"; 
   d="scan'208";a="48897921"
Received: from fmviesa004.fm.intel.com ([10.60.135.144])
  by fmvoesa113.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 21 May 2025 00:56:32 -0700
X-CSE-ConnectionGUID: 9i3Bfrw5RSmYd+TshRMIJg==
X-CSE-MsgGUID: ACWTSoI+SsCEVSZaYpY0BQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.15,303,1739865600"; 
   d="scan'208";a="145196689"
Received: from lkp-server01.sh.intel.com (HELO 1992f890471c) ([10.239.97.150])
  by fmviesa004.fm.intel.com with ESMTP; 21 May 2025 00:56:32 -0700
Received: from kbuild by 1992f890471c with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1uHeJR-000O0S-1f;
	Wed, 21 May 2025 07:56:29 +0000
Date: Wed, 21 May 2025 15:55:40 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:rdt-aet-v5 28/29]
 arch/x86/kernel/cpu/resctrl/intel_aet.c:288:63: sparse: sparse: incorrect
 type in initializer (different address spaces)
Message-ID: <202505211506.gIuGNQZ7-lkp@intel.com>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git rdt-aet-v5
head:   a0273c92f4de70daf85926f88e122a66de5bf943
commit: 113e20da9990a521c6106188f9c662fc9f745bb3 [28/29] x86/resctrl: Add info/PERF_PKG_MON/status file
config: x86_64-randconfig-121-20250521 (https://download.01.org/0day-ci/archive/20250521/202505211506.gIuGNQZ7-lkp@intel.com/config)
compiler: gcc-12 (Debian 12.2.0-14) 12.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20250521/202505211506.gIuGNQZ7-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202505211506.gIuGNQZ7-lkp@intel.com/

sparse warnings: (new ones prefixed by >>)
>> arch/x86/kernel/cpu/resctrl/intel_aet.c:288:63: sparse: sparse: incorrect type in initializer (different address spaces) @@     expected void *[noderef] __iomem info @@     got void [noderef] __iomem * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:288:63: sparse:     expected void *[noderef] __iomem info
   arch/x86/kernel/cpu/resctrl/intel_aet.c:288:63: sparse:     got void [noderef] __iomem *
>> arch/x86/kernel/cpu/resctrl/intel_aet.c:292:31: sparse: sparse: incorrect type in argument 1 (different address spaces) @@     expected void const volatile [noderef] __iomem *addr @@     got void * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:292:31: sparse:     expected void const volatile [noderef] __iomem *addr
   arch/x86/kernel/cpu/resctrl/intel_aet.c:292:31: sparse:     got void *
   arch/x86/kernel/cpu/resctrl/intel_aet.c:294:31: sparse: sparse: incorrect type in argument 1 (different address spaces) @@     expected void const volatile [noderef] __iomem *addr @@     got void * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:294:31: sparse:     expected void const volatile [noderef] __iomem *addr
   arch/x86/kernel/cpu/resctrl/intel_aet.c:294:31: sparse:     got void *
   arch/x86/kernel/cpu/resctrl/intel_aet.c:296:31: sparse: sparse: incorrect type in argument 1 (different address spaces) @@     expected void const volatile [noderef] __iomem *addr @@     got void * @@
   arch/x86/kernel/cpu/resctrl/intel_aet.c:296:31: sparse:     expected void const volatile [noderef] __iomem *addr
   arch/x86/kernel/cpu/resctrl/intel_aet.c:296:31: sparse:     got void *
   arch/x86/kernel/cpu/resctrl/intel_aet.c:292:26: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:292:26: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:294:26: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:294:26: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:296:26: sparse: sparse: dereference of noderef expression
   arch/x86/kernel/cpu/resctrl/intel_aet.c:296:26: sparse: sparse: dereference of noderef expression

vim +288 arch/x86/kernel/cpu/resctrl/intel_aet.c

   285	
   286	static void show_debug(struct seq_file *s, struct event_group *e, int pkg, int instance)
   287	{
 > 288		void *info __iomem = e->pkginfo[pkg]->addrs[instance] + e->mmio_size;
   289	
   290		/* Information registers are the last three qwords in MMIO space */
   291		seq_printf(s, "%s %d:%d agg_data_loss_count = %llu\n", e->name, pkg, instance,
 > 292			   readq(info - 24));
   293		seq_printf(s, "%s %d:%d agg_data_loss_timestamp = %llu\n", e->name, pkg, instance,
   294			   readq(info - 16));
   295		seq_printf(s, "%s %d:%d last_update_timestamp = %llu\n", e->name, pkg, instance,
   296			   readq(info - 8));
   297	}
   298	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
