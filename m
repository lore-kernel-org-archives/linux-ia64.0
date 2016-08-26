From: kbuild test robot <lkp@intel.com>
Date: Fri, 26 Aug 2016 20:18:24 +0000
Subject: Re: [PATCH 1/5] IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <201608270402.1KUEPv51%fengguang.wu@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
List-Id: <linux-ia64.vger.kernel.org>
References: <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
In-Reply-To: <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
To: linux-ia64@vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Markus,

[auto build test ERROR on ia64/next]
[also build test ERROR on v4.8-rc3]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/SF-Markus-Elfring/IA64-Fine-tuning-for-some-function-implementations/20160827-021651
base:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git next
config: ia64-allnoconfig (attached as .config)
compiler: ia64-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=ia64 

All errors (new ones prefixed by >>):

   arch/ia64/sn/kernel/irq.c: In function 'sn_irq_lh_init':
>> arch/ia64/sn/kernel/irq.c:482:18: error: incompatible type for argument 1 of 'kmalloc'
      sn_irq_lh[i] = kmalloc(*sn_irq_lh[i], GFP_KERNEL);
                     ^
   In file included from arch/ia64/sn/kernel/irq.c:15:0:
   include/linux/slab.h:466:30: note: expected 'size_t' but argument is of type 'struct list_head'
    static __always_inline void *kmalloc(size_t size, gfp_t flags)
                                 ^

vim +/kmalloc +482 arch/ia64/sn/kernel/irq.c

   476	
   477		sn_irq_lh = kmalloc_array(NR_IRQS, sizeof(*sn_irq_lh), GFP_KERNEL);
   478		if (!sn_irq_lh)
   479			panic("SN PCI INIT: Failed to allocate memory for PCI init\n");
   480	
   481		for (i = 0; i < NR_IRQS; i++) {
 > 482			sn_irq_lh[i] = kmalloc(*sn_irq_lh[i], GFP_KERNEL);
   483			if (!sn_irq_lh[i])
   484				panic("SN PCI INIT: Failed IRQ memory allocation\n");
   485	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--WIyZ46R2i8wDzkSu
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--WIyZ46R2i8wDzkSu--
