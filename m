Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F6593C2F
	for <linux-ia64@vger.kernel.org>; Fri, 27 Jun 2025 07:36:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751009791; cv=none; b=MgZmjsKTGdxtHYo1Br7CFMzD35qDmL/U0OvVa0v2+/iABUzjlJTfNXIQws7WIx2Z95WT6rRsMXMGoTmGKIS06O/H1GUt4Ziukhr/B/LOTJs4TfBNkkb3t4+XPGg5xCIHv1omRy4FHjc08UOQ0XjQnb1jzMylA11b2huAxrbNpow=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751009791; c=relaxed/simple;
	bh=hNVftWQ63rFf3Ee+kqeNtyEvtbH+AVjgbBrH7OnWLLM=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=MYWGOxSQtoLzwuTvaotsW52PyB8hkXr26xrgmUY5Tkjr8qeiLKjE9BSLx+G4FmRLssI5BMJWVe9OLkhBdMf/ktRkEsxr5gwoTYl9gMr/MrCKSqOUquQj50lK+n1CWlJCI80bFYiIrIHKOj96MYlzSOzR39C2cSMshXyw8GPzNvU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=F9ATPWsl; arc=none smtp.client-ip=198.175.65.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="F9ATPWsl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1751009789; x=1782545789;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=hNVftWQ63rFf3Ee+kqeNtyEvtbH+AVjgbBrH7OnWLLM=;
  b=F9ATPWslcPc344cRCXuJuio7Rd9Xy1q35WyddENcsTO1w9ZM6Ffue/cw
   kdmBOG+b23pdKIrHOzVSDs+zzj+sH9oMyG3itmNzLT8q7qdkI+Du/3dKd
   4P1JlqntlD7dP0C8rqc4AMuEtUGOqMTs1NMZW6EMfoNafTSj2almCTtCR
   IkAJHiY0G6zF2RBePrd6xWwcj1uGRQNK/Ty5kekOJqnKfOzwMX1UxJ+9Y
   CZ8cnkXKkhfqQWNREKLCWx1Fbat/Cka1D0zPrl7i8zKIyDwXb/ep5gYjT
   Fvg25qIQ/sgdigPihnU17RX1dN3Hb1TasfmdIkCI093pmsbPbeYVQgCcF
   g==;
X-CSE-ConnectionGUID: B1Mb0s89QL+5Wo+0cxq0Zw==
X-CSE-MsgGUID: Ae2OKUoqTxqlk0maHEGDVQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11476"; a="53190630"
X-IronPort-AV: E=Sophos;i="6.16,269,1744095600"; 
   d="scan'208";a="53190630"
Received: from fmviesa008.fm.intel.com ([10.60.135.148])
  by orvoesa111.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jun 2025 00:36:28 -0700
X-CSE-ConnectionGUID: o3bktFEcTtm9W/DXCZaF6Q==
X-CSE-MsgGUID: 8G8zR2RDTcSE2e8mjx5iFw==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.16,269,1744095600"; 
   d="scan'208";a="153256706"
Received: from lkp-server01.sh.intel.com (HELO e8142ee1dce2) ([10.239.97.150])
  by fmviesa008.fm.intel.com with ESMTP; 27 Jun 2025 00:36:26 -0700
Received: from kbuild by e8142ee1dce2 with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1uV3dI-000VvX-0e;
	Fri, 27 Jun 2025 07:36:24 +0000
Date: Fri, 27 Jun 2025 15:35:58 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: Paul Gazzillo <paul@pgazz.com>,
	Necip Fazil Yildiran <fazilyildiran@gmail.com>,
	oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:rdt-aet-v6 32/45] kismet: WARNING: unmet direct dependencies
 detected for INTEL_RAPL_CORE when selected by INTEL_RAPL_TPMI
Message-ID: <202506271542.l76jdSsw-lkp@intel.com>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git rdt-aet-v6
head:   453022799f324c7f532802ec2fd27a72c32bd4be
commit: d1d8a56c5343bbc768611ca1757528d36130acfc [32/45] x86/resctrl: Discover hardware telemetry events
config: x86_64-kismet-CONFIG_INTEL_RAPL_CORE-CONFIG_INTEL_RAPL_TPMI-0-0 (https://download.01.org/0day-ci/archive/20250627/202506271542.l76jdSsw-lkp@intel.com/config)
reproduce: (https://download.01.org/0day-ci/archive/20250627/202506271542.l76jdSsw-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202506271542.l76jdSsw-lkp@intel.com/

kismet warnings: (new ones prefixed by >>)
>> kismet: WARNING: unmet direct dependencies detected for INTEL_RAPL_CORE when selected by INTEL_RAPL_TPMI
   WARNING: unmet direct dependencies detected for INTEL_VSEC
     Depends on [n]: X86_PLATFORM_DEVICES [=y] && PCI [=n]
     Selected by [y]:
     - X86_CPU_RESCTRL [=y] && X86 [=y] && (CPU_SUP_INTEL [=y] || CPU_SUP_AMD [=y]) && MISC_FILESYSTEMS [=y]
   
   WARNING: unmet direct dependencies detected for INTEL_RAPL_CORE
     Depends on [n]: POWERCAP [=y] && PCI [=n]
     Selected by [y]:
     - INTEL_RAPL_TPMI [=y] && POWERCAP [=y] && X86 [=y] && INTEL_TPMI [=y]

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
