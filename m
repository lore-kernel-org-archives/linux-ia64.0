From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Wed, 06 Jun 2001 21:43:27 +0000
Subject: [Linux-ia64] efi_dir defined within "CONFIG_PROC_FS" but used unconditionally
Message-Id: <marc-linux-ia64-105590693005692@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a minor bug in the 2.4.5 source that ought to be fixed.  In
arch/ia64/kernel/efi.c, efi_dir is declared conditionally on CONFIG_PROC_FS,
but it is referenced in the function efivars_exit without any conditional
compilation.


