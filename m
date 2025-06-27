Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93B2F293C7B
	for <linux-ia64@vger.kernel.org>; Fri, 27 Jun 2025 09:13:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751015621; cv=none; b=Vh2s06q64t7CdJSL1w6hCdI3KaU5jrv+7aNACIm4kWHtrfblYge6DLkBQVd0sD3ECvDY902/JlzgteQn8HGps6kYtkMplnD//gk/zuaYnTkBI7yNiuNED+ph0KT7Tu8eERsFyQErsqgJsLPEZ8EZ9FRztrMxRNFlGJ2HQ3+kTF0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751015621; c=relaxed/simple;
	bh=jk5eEJqxeTiyTrWCP6RDQtV2xVuEM8vkh/6KgdOzCT0=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=KPGzWN/5/7YtoyNV4PW0LtTWK1UIM6Ud2oWXNT7wmqHS0nXwm+9VWgRUMo4ziXWgthcr9MSJr5XH94dAGs3EBB9APj0bCPr7GfUdBZrGIlmWlGu7XN6N8jdoUbIk5luE1yqYNNsjn9nsOi0QRghH7O/vJr3yko+m4vMapb+rwl8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=JjfOA4If; arc=none smtp.client-ip=198.175.65.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="JjfOA4If"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1751015620; x=1782551620;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=jk5eEJqxeTiyTrWCP6RDQtV2xVuEM8vkh/6KgdOzCT0=;
  b=JjfOA4IfU369iavN1oG1jAaXrZSkxHM0oMAgR3sl7eE21Rv1M3QZsVEV
   EO8YYXW8gMLXU+DD9OVSwnAVvBq+JF4orGnFyukPSxsO80u33Twlzd7oi
   NwGoYVDXvl0sgHw5hTLvaimu4A8uxNXKLwlZcgCxHDfsN9UxFKEFpBvm7
   S5GK487ZT+252NVS9/K2xRp5XtUYMzZd9fpUsIrnEBdJ5MP2DNvV44hHi
   tqpCNd+T2cedX/WvzvzmqWKvzrQI9C9qnTH28Mh5mTNIGQP1QnNU3zuYw
   8oSw5ioCrtbX7HV4DeqRf9r64H+PucbArhQh/5ZiSOJUkAprrWG3cafr/
   g==;
X-CSE-ConnectionGUID: ERoGii0LQ32YOBMfCdAC8g==
X-CSE-MsgGUID: km01mPAEQiOwsVDuyOIkjQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11476"; a="53198460"
X-IronPort-AV: E=Sophos;i="6.16,270,1744095600"; 
   d="scan'208";a="53198460"
Received: from fmviesa003.fm.intel.com ([10.60.135.143])
  by orvoesa111.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jun 2025 02:13:39 -0700
X-CSE-ConnectionGUID: Wo4TDrp/Rp23P7DzHKZlLg==
X-CSE-MsgGUID: rbLbaazsS36TXCWrUgbrcQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.16,270,1744095600"; 
   d="scan'208";a="156797009"
Received: from lkp-server01.sh.intel.com (HELO e8142ee1dce2) ([10.239.97.150])
  by fmviesa003.fm.intel.com with ESMTP; 27 Jun 2025 02:13:37 -0700
Received: from kbuild by e8142ee1dce2 with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1uV59L-000W12-1g;
	Fri, 27 Jun 2025 09:13:35 +0000
Date: Fri, 27 Jun 2025 17:13:19 +0800
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: Paul Gazzillo <paul@pgazz.com>,
	Necip Fazil Yildiran <fazilyildiran@gmail.com>,
	oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: [aegl:rdt-aet-v6 32/45] kismet: WARNING: unmet direct dependencies
 detected for INTEL_VSEC when selected by X86_CPU_RESCTRL
Message-ID: <202506271635.dswYwBMG-lkp@intel.com>
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
config: x86_64-kismet-CONFIG_INTEL_VSEC-CONFIG_X86_CPU_RESCTRL-0-0 (https://download.01.org/0day-ci/archive/20250627/202506271635.dswYwBMG-lkp@intel.com/config)
reproduce: (https://download.01.org/0day-ci/archive/20250627/202506271635.dswYwBMG-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202506271635.dswYwBMG-lkp@intel.com/

kismet warnings: (new ones prefixed by >>)
>> kismet: WARNING: unmet direct dependencies detected for INTEL_VSEC when selected by X86_CPU_RESCTRL
   WARNING: unmet direct dependencies detected for INTEL_VSEC
     Depends on [n]: X86_PLATFORM_DEVICES [=y] && PCI [=n]
     Selected by [y]:
     - X86_CPU_RESCTRL [=y] && X86 [=y] && (CPU_SUP_INTEL [=y] || CPU_SUP_AMD [=y]) && MISC_FILESYSTEMS [=y]

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
