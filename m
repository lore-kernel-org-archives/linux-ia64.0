From: kbuild test robot <fengguang.wu@intel.com>
Date: Tue, 13 Nov 2012 19:53:58 +0000
Subject: drivers/firmware/efivars.c:841:2: warning: (near initialization for 'efi_pstore_info.write')
Message-Id: <50a2a556.xHv7z/JfnUYzt0/E%fengguang.wu@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git next
head:   76cd4d5438b751f661464a0273af218fed4838c7
commit: e486ef81d16c30956b9e9709580cb03cc20740eb efi_pstore: Add a sequence counter to a variable name
date:   89 minutes ago
config: make ARCH=ia64 defconfig

All warnings:

drivers/firmware/efivars.c:841:2: warning: initialization from incompatible pointer type [enabled by default]
drivers/firmware/efivars.c:841:2: warning: (near initialization for 'efi_pstore_info.write') [enabled by default]
drivers/firmware/efivars.c:842:2: warning: initialization from incompatible pointer type [enabled by default]
drivers/firmware/efivars.c:842:2: warning: (near initialization for 'efi_pstore_info.erase') [enabled by default]

vim +841 drivers/firmware/efivars.c

5ee9c198 Matthew Garrett    2011-07-21  825  	return 0;
5ee9c198 Matthew Garrett    2011-07-21  826  }
5ee9c198 Matthew Garrett    2011-07-21  827  
5ee9c198 Matthew Garrett    2011-07-21  828  static int efi_pstore_erase(enum pstore_type_id type, u64 id,
5ee9c198 Matthew Garrett    2011-07-21  829  			    struct pstore_info *psi)
5ee9c198 Matthew Garrett    2011-07-21  830  {
5ee9c198 Matthew Garrett    2011-07-21  831  	return 0;
5ee9c198 Matthew Garrett    2011-07-21  832  }
5ee9c198 Matthew Garrett    2011-07-21  833  #endif
5ee9c198 Matthew Garrett    2011-07-21  834  
5ee9c198 Matthew Garrett    2011-07-21  835  static struct pstore_info efi_pstore_info = {
5ee9c198 Matthew Garrett    2011-07-21  836  	.owner		= THIS_MODULE,
5ee9c198 Matthew Garrett    2011-07-21  837  	.name		= "efi",
5ee9c198 Matthew Garrett    2011-07-21  838  	.open		= efi_pstore_open,
5ee9c198 Matthew Garrett    2011-07-21  839  	.close		= efi_pstore_close,
5ee9c198 Matthew Garrett    2011-07-21  840  	.read		= efi_pstore_read,
5ee9c198 Matthew Garrett    2011-07-21 @841  	.write		= efi_pstore_write,
5ee9c198 Matthew Garrett    2011-07-21  842  	.erase		= efi_pstore_erase,
5ee9c198 Matthew Garrett    2011-07-21  843  };
^1da177e Linus Torvalds     2005-04-16  844  
2c3c8bea Chris Wright       2010-05-12  845  static ssize_t efivar_create(struct file *filp, struct kobject *kobj,
97fa5bb7 Greg Kroah-Hartman 2007-11-07  846  			     struct bin_attribute *bin_attr,
97fa5bb7 Greg Kroah-Hartman 2007-11-07  847  			     char *buf, loff_t pos, size_t count)
^1da177e Linus Torvalds     2005-04-16  848  {
^1da177e Linus Torvalds     2005-04-16  849  	struct efi_variable *new_var = (struct efi_variable *)buf;

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
