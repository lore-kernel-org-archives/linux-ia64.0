From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 06 Jun 2017 08:45:16 +0000
Subject: [ia64:cqm_and_mbm 10/18] arch/x86/kernel/cpu/intel_rdt_rdtgroup.c:1122:5-9: WARNING: Unsigned expres
Message-Id: <alpine.DEB.2.20.1706061044330.3023@hadrien>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Please check on whether rmid can be signed.

julia

---------- Forwarded message ----------
Date: Tue, 6 Jun 2017 16:24:23 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: [ia64:cqm_and_mbm 10/18]
    arch/x86/kernel/cpu/intel_rdt_rdtgroup.c:1122:5-9: WARNING: Unsigned
    expression compared with zero: rmid < 0

CC: kbuild-all@01.org
CC: linux-ia64@vger.kernel.org
TO: Vikas Shivappa <vikas.shivappa@linux.intel.com>
CC: Tony Luck <tony.luck@intel.com>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git cqm_and_mbm
head:   e1a50409e356aed21c7a822b513cef97ca74934b
commit: aae042f2b4e0961dea80c859d3128c47b66d499b [10/18] x86/intel_rdt/cqm: Add mkdir support for RDT monitoring
:::::: branch date: 9 hours ago
:::::: commit date: 9 hours ago

>> arch/x86/kernel/cpu/intel_rdt_rdtgroup.c:1122:5-9: WARNING: Unsigned expression compared with zero: rmid < 0

git remote add ia64 https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git
git remote update ia64
git checkout aae042f2b4e0961dea80c859d3128c47b66d499b
vim +1122 arch/x86/kernel/cpu/intel_rdt_rdtgroup.c

5ff193fb Fenghua Yu     2016-10-28  1106  	kernfs_kill_sb(sb);
5ff193fb Fenghua Yu     2016-10-28  1107  	mutex_unlock(&rdtgroup_mutex);
5ff193fb Fenghua Yu     2016-10-28  1108  }
5ff193fb Fenghua Yu     2016-10-28  1109
5ff193fb Fenghua Yu     2016-10-28  1110  static struct file_system_type rdt_fs_type = {
5ff193fb Fenghua Yu     2016-10-28  1111  	.name    = "resctrl",
5ff193fb Fenghua Yu     2016-10-28  1112  	.mount   = rdt_mount,
5ff193fb Fenghua Yu     2016-10-28  1113  	.kill_sb = rdt_kill_sb,
5ff193fb Fenghua Yu     2016-10-28  1114  };
5ff193fb Fenghua Yu     2016-10-28  1115
aae042f2 Vikas Shivappa 2017-06-03  1116  static int mkdir_rdt_common(struct kernfs_node *kn, enum rdt_group_type rtype,
aae042f2 Vikas Shivappa 2017-06-03  1117  			    struct rdtgroup *rdtgrp)
aae042f2 Vikas Shivappa 2017-06-03  1118  {
aae042f2 Vikas Shivappa 2017-06-03  1119  	u32 rmid;
aae042f2 Vikas Shivappa 2017-06-03  1120
aae042f2 Vikas Shivappa 2017-06-03  1121  	rmid = alloc_rmid();
aae042f2 Vikas Shivappa 2017-06-03 @1122  	if (rmid < 0)
aae042f2 Vikas Shivappa 2017-06-03  1123  		return rmid;
aae042f2 Vikas Shivappa 2017-06-03  1124
aae042f2 Vikas Shivappa 2017-06-03  1125  	rdtgrp->rmid = rmid;
aae042f2 Vikas Shivappa 2017-06-03  1126  	rdtgrp->type = rtype;
aae042f2 Vikas Shivappa 2017-06-03  1127
aae042f2 Vikas Shivappa 2017-06-03  1128  	return 0;
aae042f2 Vikas Shivappa 2017-06-03  1129  }
aae042f2 Vikas Shivappa 2017-06-03  1130

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
