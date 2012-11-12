From: kbuild test robot <fengguang.wu@intel.com>
Date: Mon, 12 Nov 2012 21:43:27 +0000
Subject: fs/pstore/platform.c:175:3: error: too few arguments to function 'psinfo->write'
Message-Id: <50a16d7f./pVyLLFGO2zYdnIn%fengguang.wu@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git next
head:   16e4591b892978586ec79b003665f46528cf19a9
commit: 7c0e29acbf054eff3e9d32f6b434d60cd19468e9 efi_pstore: Add a sequence counter to a variable name
date:   31 minutes ago
config: make ARCH=x86_64 allmodconfig

All error/warnings:

fs/pstore/platform.c: In function 'pstore_console_write':
fs/pstore/platform.c:175:3: warning: passing argument 6 of 'psinfo->write' makes integer from pointer without a cast [enabled by default]
fs/pstore/platform.c:175:3: note: expected 'size_t' but argument is of type 'struct pstore_info *'
fs/pstore/platform.c:175:3: error: too few arguments to function 'psinfo->write'

vim +175 fs/pstore/platform.c

80c9d03c Chuansheng Liu  2012-09-18  169  			if (!spin_trylock_irqsave(&psinfo->buf_lock, flags))
80c9d03c Chuansheng Liu  2012-09-18  170  				break;
80c9d03c Chuansheng Liu  2012-09-18  171  		} else {
80c9d03c Chuansheng Liu  2012-09-18  172  			spin_lock_irqsave(&psinfo->buf_lock, flags);
80c9d03c Chuansheng Liu  2012-09-18  173  		}
f29e5956 Anton Vorontsov 2012-05-26  174  		memcpy(psinfo->buf, s, c);
f29e5956 Anton Vorontsov 2012-05-26 @175  		psinfo->write(PSTORE_TYPE_CONSOLE, 0, NULL, 0, c, psinfo);
f29e5956 Anton Vorontsov 2012-05-26  176  		spin_unlock_irqrestore(&psinfo->buf_lock, flags);
f29e5956 Anton Vorontsov 2012-05-26  177  		s += c;
f29e5956 Anton Vorontsov 2012-05-26  178  		c = e - s;

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
