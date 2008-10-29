From: Jay Lan <jlan@sgi.com>
Date: Wed, 29 Oct 2008 00:49:51 +0000
Subject: [IA64] kdump failed to produce vmcore in 2.6.28-rc2
Message-Id: <4907B32F.4030009@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "kexec@lists.infradead.org" <kexec@lists.infradead.org>

Booting up a 2.6.28-rc2 kdump kernel, i observed these
messages at console:

  Warning: Core image elf header not found
  Kdump: vmcore not initialized

It was a default configuration with a new config flag
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS set to 'y'.

The machine worked fine with 2.6.27.

Regards,
jay
