From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Sep 2002 21:48:37 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590701906074@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new ia64 patch is now availabe at
ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:

	linux-2.5.39-ia64-020928.gz

For a detailed changelog etc., see
http://lia64.bkbits.net:8080/to-linus-2.5 as usual.

The major change in this patch is that I switched the IOSAPIC code
over to use the ACPI subsystem.  This brings us more in sync with the
x86 tree and avoids code duplication.  I tested this both on Big Sur
and zx1 and it seems to work fine.  The integration is not perfect
yet, because on ia64 linux the irq number is still different from the
ACPI GSI (for no good reason, IMHO).  Hopefully, someone can take a
look into changing this.

I'd like to encourage all developers to try out this kernel.  We don't
want to end up in a situation where dozens of new bugs are discovered
a day before v2.6 is released (not that this is going to happen very
soon, but we are approaching feature freeze very quickly...).

Enjoy,

	--david

