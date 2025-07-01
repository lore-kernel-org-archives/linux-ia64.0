Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9E41264F87
	for <linux-ia64@vger.kernel.org>; Tue,  1 Jul 2025 09:27:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751362025; cv=none; b=YWOQoidw+I7FSPBDww8jA9q9XXrsSkx54wE1vpO44BQJ/3MxSTkg8a00Iow8ZdANEySsuEWI+9Up7FO4WUcn+hcBKJCdIn9q4SnIlDg2t2voHycyo7HY5yn2ljjQuNOpL+sDQIBqVlDLDmhkInT3AY8pAAq1UCmk7J7ZLUYMaVk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751362025; c=relaxed/simple;
	bh=7LJS3CBA8LET/cy8Pby9VvnMFR9KiVJjxldTSSd2KhQ=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=o3fx7STtRYKYd6qza5WwbBK69fxeUkNvfoNCOxaZ0yo60dB+bwA9fDE4RxQj1kBq+a8PglZgHKrLoivEG8CVczokBQqZva/UNiFLanzYilEnOTG4RVV8ON378sThJEI8hf0ICyUialQ0XhXEBDK6SlASucYuJyiDy/N6ELGcI2A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=MQKXZAq5; arc=none smtp.client-ip=192.198.163.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="MQKXZAq5"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1751362024; x=1782898024;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=7LJS3CBA8LET/cy8Pby9VvnMFR9KiVJjxldTSSd2KhQ=;
  b=MQKXZAq5o6NR41neuMcTci1v+24DV6ISITNoSQmpQxKqMAdFqh2UQL1Y
   hNhssqy+0dKWsbOmQJT4BYg607PJGEUrQpCotxR+30daE+vzWFLNdUQ74
   TlCzF0uX8YfBJHoqlClErY/T1357MHoWw5E3sJ7xZyQJ0ndcJw0asIZkp
   0mxLn5zhHKcTrUXo4u6souHbJyeSjKe2lx6z+tKsnyt4n0V73654QaEtZ
   XbEM3LLkB+1NvCTY7czSjyx2XUUSwwgzWcRvlMnkfEivljxu82HfNtxI2
   8BhuR0KC8X8zM4UOetZuJwqGdra4rHWJEHiiqN5WD6intP59GF5CoquqF
   g==;
X-CSE-ConnectionGUID: e9XkLcOtQB67eFeX0YC5xA==
X-CSE-MsgGUID: K/JzlxpMSBCtx4yPd2HEmQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11480"; a="64220777"
X-IronPort-AV: E=Sophos;i="6.16,279,1744095600"; 
   d="scan'208";a="64220777"
Received: from orviesa005.jf.intel.com ([10.64.159.145])
  by fmvoesa105.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 01 Jul 2025 02:27:03 -0700
X-CSE-ConnectionGUID: e9S9wjriR7iNLbDydL1h3Q==
X-CSE-MsgGUID: o8M2ufxYSsukqDUz7wGabg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.16,279,1744095600"; 
   d="scan'208";a="159431601"
Received: from igk-lkp-server01.igk.intel.com (HELO 030a839a1121) ([10.91.175.65])
  by orviesa005.jf.intel.com with ESMTP; 01 Jul 2025 02:27:01 -0700
Received: from kbuild by 030a839a1121 with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1uWXGV-000017-1q;
	Tue, 01 Jul 2025 09:26:59 +0000
Date: Tue, 1 Jul 2025 11:26:57 +0200
From: kernel test robot <lkp@intel.com>
To: Tony Luck <tony.luck@intel.com>
Cc: llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
	linux-ia64@vger.kernel.org
Subject: [aegl:rdt-aet-v5.5 32/45] drivers/platform/x86/intel/vsec.c:486:9:
 error: call to undeclared function 'pci_find_next_ext_capability'; ISO C99
 and later do not support implicit function declarations
Message-ID: <202507011128.eWtHft5k-lkp@intel.com>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git rdt-aet-v5.5
head:   453022799f324c7f532802ec2fd27a72c32bd4be
commit: d1d8a56c5343bbc768611ca1757528d36130acfc [32/45] x86/resctrl: Discover hardware telemetry events
config: x86_64-buildonly-randconfig-2003-20250701 (https://download.01.org/0day-ci/archive/20250701/202507011128.eWtHft5k-lkp@intel.com/config)
compiler: clang version 20.1.7 (https://github.com/llvm/llvm-project 6146a88f60492b520a36f8f8f3231e15f3cc6082)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20250701/202507011128.eWtHft5k-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202507011128.eWtHft5k-lkp@intel.com/

All errors (new ones prefixed by >>):

>> drivers/platform/x86/intel/vsec.c:486:9: error: call to undeclared function 'pci_find_next_ext_capability'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
     486 |                 pos = pci_find_next_ext_capability(pdev, pos, PCI_EXT_CAP_ID_DVSEC);
         |                       ^
   drivers/platform/x86/intel/vsec.c:486:9: note: did you mean 'pci_find_next_capability'?
   include/linux/pci.h:2060:18: note: 'pci_find_next_capability' declared here
    2060 | static inline u8 pci_find_next_capability(struct pci_dev *dev, u8 post, int cap)
         |                  ^
   drivers/platform/x86/intel/vsec.c:535:9: error: call to undeclared function 'pci_find_next_ext_capability'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
     535 |                 pos = pci_find_next_ext_capability(pdev, pos, PCI_EXT_CAP_ID_VNDR);
         |                       ^
>> drivers/platform/x86/intel/vsec.c:844:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
     844 | module_pci_driver(intel_vsec_pci_driver);
         | ^
         | int
>> drivers/platform/x86/intel/vsec.c:844:19: error: a parameter list without types is only allowed in a function definition
     844 | module_pci_driver(intel_vsec_pci_driver);
         |                   ^
   4 errors generated.

Kconfig warnings: (for reference only)
   WARNING: unmet direct dependencies detected for INTEL_VSEC
   Depends on [n]: X86_PLATFORM_DEVICES [=y] && PCI [=n]
   Selected by [y]:
   - X86_CPU_RESCTRL [=y] && X86 [=y] && (CPU_SUP_INTEL [=y] || CPU_SUP_AMD [=n]) && MISC_FILESYSTEMS [=y]


vim +/pci_find_next_ext_capability +486 drivers/platform/x86/intel/vsec.c

a3c8f906ed5fc1 David E. Box 2021-12-07  473  
f21c179e1206e8 David E. Box 2022-06-29  474  static bool intel_vsec_walk_dvsec(struct pci_dev *pdev,
f21c179e1206e8 David E. Box 2022-06-29  475  				  struct intel_vsec_platform_info *info)
a3c8f906ed5fc1 David E. Box 2021-12-07  476  {
a3c8f906ed5fc1 David E. Box 2021-12-07  477  	bool have_devices = false;
a3c8f906ed5fc1 David E. Box 2021-12-07  478  	int pos = 0;
a3c8f906ed5fc1 David E. Box 2021-12-07  479  
a3c8f906ed5fc1 David E. Box 2021-12-07  480  	do {
a3c8f906ed5fc1 David E. Box 2021-12-07  481  		struct intel_vsec_header header;
a3c8f906ed5fc1 David E. Box 2021-12-07  482  		u32 table, hdr;
a3c8f906ed5fc1 David E. Box 2021-12-07  483  		u16 vid;
a3c8f906ed5fc1 David E. Box 2021-12-07  484  		int ret;
a3c8f906ed5fc1 David E. Box 2021-12-07  485  
a3c8f906ed5fc1 David E. Box 2021-12-07 @486  		pos = pci_find_next_ext_capability(pdev, pos, PCI_EXT_CAP_ID_DVSEC);
a3c8f906ed5fc1 David E. Box 2021-12-07  487  		if (!pos)
a3c8f906ed5fc1 David E. Box 2021-12-07  488  			break;
a3c8f906ed5fc1 David E. Box 2021-12-07  489  
a3c8f906ed5fc1 David E. Box 2021-12-07  490  		pci_read_config_dword(pdev, pos + PCI_DVSEC_HEADER1, &hdr);
a3c8f906ed5fc1 David E. Box 2021-12-07  491  		vid = PCI_DVSEC_HEADER1_VID(hdr);
a3c8f906ed5fc1 David E. Box 2021-12-07  492  		if (vid != PCI_VENDOR_ID_INTEL)
a3c8f906ed5fc1 David E. Box 2021-12-07  493  			continue;
a3c8f906ed5fc1 David E. Box 2021-12-07  494  
a3c8f906ed5fc1 David E. Box 2021-12-07  495  		/* Support only revision 1 */
a3c8f906ed5fc1 David E. Box 2021-12-07  496  		header.rev = PCI_DVSEC_HEADER1_REV(hdr);
a3c8f906ed5fc1 David E. Box 2021-12-07  497  		if (header.rev != 1) {
a3c8f906ed5fc1 David E. Box 2021-12-07  498  			dev_info(&pdev->dev, "Unsupported DVSEC revision %d\n", header.rev);
a3c8f906ed5fc1 David E. Box 2021-12-07  499  			continue;
a3c8f906ed5fc1 David E. Box 2021-12-07  500  		}
a3c8f906ed5fc1 David E. Box 2021-12-07  501  
a3c8f906ed5fc1 David E. Box 2021-12-07  502  		header.length = PCI_DVSEC_HEADER1_LEN(hdr);
a3c8f906ed5fc1 David E. Box 2021-12-07  503  
a3c8f906ed5fc1 David E. Box 2021-12-07  504  		pci_read_config_byte(pdev, pos + INTEL_DVSEC_ENTRIES, &header.num_entries);
a3c8f906ed5fc1 David E. Box 2021-12-07  505  		pci_read_config_byte(pdev, pos + INTEL_DVSEC_SIZE, &header.entry_size);
a3c8f906ed5fc1 David E. Box 2021-12-07  506  		pci_read_config_dword(pdev, pos + INTEL_DVSEC_TABLE, &table);
a3c8f906ed5fc1 David E. Box 2021-12-07  507  
a3c8f906ed5fc1 David E. Box 2021-12-07  508  		header.tbir = INTEL_DVSEC_TABLE_BAR(table);
a3c8f906ed5fc1 David E. Box 2021-12-07  509  		header.offset = INTEL_DVSEC_TABLE_OFFSET(table);
a3c8f906ed5fc1 David E. Box 2021-12-07  510  
a3c8f906ed5fc1 David E. Box 2021-12-07  511  		pci_read_config_dword(pdev, pos + PCI_DVSEC_HEADER2, &hdr);
a3c8f906ed5fc1 David E. Box 2021-12-07  512  		header.id = PCI_DVSEC_HEADER2_ID(hdr);
a3c8f906ed5fc1 David E. Box 2021-12-07  513  
7e734fc397c852 David E. Box 2025-06-16  514  		ret = intel_vsec_register_device(pdev, &header, info);
a3c8f906ed5fc1 David E. Box 2021-12-07  515  		if (ret)
a3c8f906ed5fc1 David E. Box 2021-12-07  516  			continue;
a3c8f906ed5fc1 David E. Box 2021-12-07  517  
a3c8f906ed5fc1 David E. Box 2021-12-07  518  		have_devices = true;
a3c8f906ed5fc1 David E. Box 2021-12-07  519  	} while (true);
a3c8f906ed5fc1 David E. Box 2021-12-07  520  
a3c8f906ed5fc1 David E. Box 2021-12-07  521  	return have_devices;
a3c8f906ed5fc1 David E. Box 2021-12-07  522  }
a3c8f906ed5fc1 David E. Box 2021-12-07  523  

:::::: The code at line 486 was first introduced by commit
:::::: a3c8f906ed5fc1d4895b5e1a5c6ad6e942d6c0ca platform/x86/intel: Move intel_pmt from MFD to Auxiliary Bus

:::::: TO: David E. Box <david.e.box@linux.intel.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
