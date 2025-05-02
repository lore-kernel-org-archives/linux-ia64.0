Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEBD71E260D
	for <linux-ia64@vger.kernel.org>; Fri,  2 May 2025 07:31:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746171094; cv=none; b=L/dy5MP+WuqSdV2RmnN0u/RJeCxUC2808VuF5KdrXndQDEyYBQpLEYYFpKwj93iSKMTtvV6hx2EzGMK41uJrxLaNThOgsXg0G4TzLkDP9NeSK/FG3/3R2BDIpT8dsSZ3iiW4cnhaXxF61WN8VxhBTV0b7de+cV0yTxWiVdw8KK4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746171094; c=relaxed/simple;
	bh=h3RFb39mWVava4W40C1vqxuSd60Hfp9s0zvup3u14lM=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=fOxt1POJoD8bFggsvLQGtWn5lJexgiGj5dsWdbPKMOEAeepRa3ka4lmpXA8uoeeLEM4Vc80Ziej835k/MuWaPTyIgEYmcE9YzhpgUkgxeeXMizl6V1rKyaADVH//FJf011BXuDDWnqnfbT/ITW8s4gIdjgUIvftwJILmPP6l5O8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=QK2n8vd3; arc=none smtp.client-ip=192.198.163.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="QK2n8vd3"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1746171093; x=1777707093;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=h3RFb39mWVava4W40C1vqxuSd60Hfp9s0zvup3u14lM=;
  b=QK2n8vd3dgdu30nUHD9cSHHMuBcmyMRQqe7pGaB3/xzCumX7l4zUghcV
   WBHSNpCnetWC5neoEUBAqpdCCABQakWqhcYhvkHhoWVDYLtMGKUHTPUnv
   jLDgjbjjgD1s5usDs5d5hlrFZv8m82nA30tHxm+P4/D+m38RoRZnfmD0u
   /9QIUJyBA8z0i8OWpnJHHXgypj39kTiJvuTcwN25l1TsKKVwycGhiz4Gx
   Mwbcq44ADUovKdI+Qg2jNqMhnZK7MSI922ClHT1QM3wD/wqNQ0cXGOKdi
   1SGI4UKRevvYJ91g+OqJgBGJW7qccnDoNvPqZ9NMBo1eC5p4wEiP1G6U6
   w==;
X-CSE-ConnectionGUID: E/cXUfFGR8+RQQrCGjiV1w==
X-CSE-MsgGUID: NauGS+XFSFynVUmzn1AJiQ==
X-IronPort-AV: E=McAfee;i="6700,10204,11420"; a="47737594"
X-IronPort-AV: E=Sophos;i="6.15,255,1739865600"; 
   d="scan'208";a="47737594"
Received: from fmviesa009.fm.intel.com ([10.60.135.149])
  by fmvoesa111.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 May 2025 00:31:32 -0700
X-CSE-ConnectionGUID: 7FxiWULmSdqaKmzNGA5DBg==
X-CSE-MsgGUID: HMM4n3SFQ4qkGxOJbIaVcg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.15,255,1739865600"; 
   d="scan'208";a="135545652"
Received: from lkp-server01.sh.intel.com (HELO 1992f890471c) ([10.239.97.150])
  by fmviesa009.fm.intel.com with ESMTP; 02 May 2025 00:31:31 -0700
Received: from kbuild by 1992f890471c with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1uAkro-0004bZ-1o;
	Fri, 02 May 2025 07:31:28 +0000
Date: Fri, 2 May 2025 15:30:53 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: Paul Gazzillo <paul@pgazz.com>,
	Necip Fazil Yildiran <fazilyildiran@gmail.com>,
	oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:rdt-aet-v4 5/31] kismet: WARNING: unmet direct dependencies
 detected for INTEL_AET_RESCTRL when selected by X86_CPU_RESCTRL
Message-ID: <202505021507.u5TMtvRx-lkp@intel.com>
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
commit: 52cf7b6965a9b1fde1506b67aefffbd82a93bcb3 [5/31] fs/resctrl: Set up Kconfig options for telemetry events
config: x86_64-kismet-CONFIG_INTEL_AET_RESCTRL-CONFIG_X86_CPU_RESCTRL-0-0 (https://download.01.org/0day-ci/archive/20250502/202505021507.u5TMtvRx-lkp@intel.com/config)
reproduce: (https://download.01.org/0day-ci/archive/20250502/202505021507.u5TMtvRx-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202505021507.u5TMtvRx-lkp@intel.com/

kismet warnings: (new ones prefixed by >>)
>> kismet: WARNING: unmet direct dependencies detected for INTEL_AET_RESCTRL when selected by X86_CPU_RESCTRL
   WARNING: unmet direct dependencies detected for INTEL_AET_RESCTRL
     Depends on [n]: X86_PLATFORM_DEVICES [=n] && INTEL_PMT_TELEMETRY [=n]
     Selected by [y]:
     - X86_CPU_RESCTRL [=y] && X86 [=y] && (CPU_SUP_INTEL [=y] || CPU_SUP_AMD [=y]) && MISC_FILESYSTEMS [=y] && X86_64 [=y] && CPU_SUP_INTEL [=y]

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
