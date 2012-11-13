From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Tue, 13 Nov 2012 19:33:57 +0000
Subject: RE: drivers/firmware/efivars.c:838:2: warning: initialization from incompatible pointer type
Message-Id: <A5ED84D3BB3A384992CBB9C77DEDA4D4138C196E@USINDEM103.corp.hds.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50a29f6c.BO5RUkPVZD3Px3vX%fengguang.wu@intel.com>
In-Reply-To: <50a29f6c.BO5RUkPVZD3Px3vX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Sorry for bothering you.
I will check all config options related to pstore..

Seiji

> -----Original Message-----
> From: kbuild test robot [mailto:fengguang.wu@intel.com]
> Sent: Tuesday, November 13, 2012 2:29 PM
> To: Seiji Aguchi
> Cc: linux-ia64@vger.kernel.org; Tony Luck
> Subject: drivers/firmware/efivars.c:838:2: warning: initialization from incompatible pointer type
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git next
> head:   76cd4d5438b751f661464a0273af218fed4838c7
> commit: e285ea1f14794593c364494cc083b5dafc9a994f efi_pstore: Add ctime to argument of erase callback
> date:   64 minutes ago
> config: make ARCH=ia64 defconfig
> 
> All warnings:
> 
> drivers/firmware/efivars.c:838:2: warning: initialization from incompatible pointer type [enabled by default]
> drivers/firmware/efivars.c:838:2: warning: (near initialization for 'efi_pstore_info.erase') [enabled by default]
> 
> vim +838 drivers/firmware/efivars.c
> 
> 5ee9c198 Matthew Garrett    2011-07-21  822  }
> 5ee9c198 Matthew Garrett    2011-07-21  823
> 5ee9c198 Matthew Garrett    2011-07-21  824  static int efi_pstore_erase(enum pstore_type_id type, u64 id,
> 5ee9c198 Matthew Garrett    2011-07-21  825  			    struct pstore_info *psi)
> 5ee9c198 Matthew Garrett    2011-07-21  826  {
> 5ee9c198 Matthew Garrett    2011-07-21  827  	return 0;
> 5ee9c198 Matthew Garrett    2011-07-21  828  }
> 5ee9c198 Matthew Garrett    2011-07-21  829  #endif
> 5ee9c198 Matthew Garrett    2011-07-21  830
> 5ee9c198 Matthew Garrett    2011-07-21  831  static struct pstore_info efi_pstore_info = {
> 5ee9c198 Matthew Garrett    2011-07-21  832  	.owner		= THIS_MODULE,
> 5ee9c198 Matthew Garrett    2011-07-21  833  	.name		= "efi",
> 5ee9c198 Matthew Garrett    2011-07-21  834  	.open		= efi_pstore_open,
> 5ee9c198 Matthew Garrett    2011-07-21  835  	.close		= efi_pstore_close,
> 5ee9c198 Matthew Garrett    2011-07-21  836  	.read		= efi_pstore_read,
> 5ee9c198 Matthew Garrett    2011-07-21  837  	.write		= efi_pstore_write,
> 5ee9c198 Matthew Garrett    2011-07-21 @838  	.erase		= efi_pstore_erase,
> 5ee9c198 Matthew Garrett    2011-07-21  839  };
> ^1da177e Linus Torvalds     2005-04-16  840
> 2c3c8bea Chris Wright       2010-05-12  841  static ssize_t efivar_create(struct file *filp, struct kobject *kobj,
> 97fa5bb7 Greg Kroah-Hartman 2007-11-07  842  			     struct bin_attribute *bin_attr,
> 97fa5bb7 Greg Kroah-Hartman 2007-11-07  843  			     char *buf, loff_t pos, size_t count)
> ^1da177e Linus Torvalds     2005-04-16  844  {
> ^1da177e Linus Torvalds     2005-04-16  845  	struct efi_variable *new_var = (struct efi_variable *)buf;
> 4142ef14 Mike Waychison     2011-03-11  846  	struct efivars *efivars = bin_attr->private;
> 
> ---
> 0-DAY kernel build testing backend         Open Source Technology Center
> Fengguang Wu, Yuanhan Liu                              Intel Corporation
