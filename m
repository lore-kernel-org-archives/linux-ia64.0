From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 29 May 2012 22:46:28 +0000
Subject: [linux-next] "x86, realmode: Move ACPI wakeup to unified realmode code" commit breaks ia64
Message-Id: <20120529224628.GB16055@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jarkko Sakkinen <jarkko.sakkinen@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <len.brown@intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-next@vger.kernel.org

Hi all,

This commit: c9b77ccb52a5c77233b0e557b7d4417b00ef4012 in linux-next

    x86, realmode: Move ACPI wakeup to unified realmode code

causes breakage on itanic:

  drivers/acpi/sleep.c:28:26: fatal error: asm/realmode.h: No such file or directory

Full log at:
	http://kisskb.ellerman.id.au/kisskb/buildresult/6395679/

Have a look if you can please.

Thanks,
Paul.

