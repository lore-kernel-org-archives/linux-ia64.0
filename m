From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 05 Oct 2000 22:08:33 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test9)
Message-Id: <marc-linux-ia64-105590678205550@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 5 Oct 2000 12:01:10 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>The latest IA-64 Linux kernel diff is now available at:
>
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
>
>in file linux-2.4.0-test9-ia64-001004.diff.

The patch contains a deletion for unistd.h~ which is not in base
2.4.0-test9.  It also deletes a lot of acpi files, which may cause
problems if you try to compile ix86 from a source tree with ia64-001004
applied, i386 config.in does not have CONFIG_ACPI_KERNEL_CONFIG.  Any
reason for these deletions and other acpi changes?

drivers/acpi/table.c
drivers/acpi/tables/Makefile
drivers/acpi/resources/Makefile
drivers/acpi/parser/psfind.c
drivers/acpi/parser/Makefile
drivers/acpi/namespace/nsdump.c
drivers/acpi/namespace/Makefile
drivers/acpi/interpreter/amdump.c
drivers/acpi/interpreter/Makefile
drivers/acpi/include/actbl.h
drivers/acpi/include/acresrc.h
drivers/acpi/include/acparser.h
drivers/acpi/include/acoutput.h
drivers/acpi/include/acnamesp.h
drivers/acpi/include/acmacros.h
drivers/acpi/include/aclocal.h
drivers/acpi/include/acinterp.h
drivers/acpi/include/achware.h
drivers/acpi/include/acglobal.h
drivers/acpi/include/acevents.h
drivers/acpi/include/acdispat.h
drivers/acpi/include/acdebug.h
drivers/acpi/include/acconfig.h
drivers/acpi/include/accommon.h
drivers/acpi/hardware/Makefile
drivers/acpi/events/Makefile
drivers/acpi/dispatcher/Makefile
drivers/acpi/common/cmclib.c
drivers/acpi/common/Makefile


