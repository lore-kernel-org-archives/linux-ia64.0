From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 07 Nov 2001 02:47:10 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.14)
Message-Id: <marc-linux-ia64-105590698805455@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 07 Nov 2001 12:48:20 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Mon, 5 Nov 2001 22:59:53 -0800, 
  Keith> David Mosberger <davidm@hpl.hp.com> wrote:
  >> linux-2.4.14-ia64-011105.diff*
  >> - support non-legacy serial ports via ACPI

  Keith> Select CONFIG_SERIAL_ACPI, get these errors.

  Keith> acpi.c: In function `acpi20_parse':
  Keith> acpi.c:462: `ACPI_SPCRT_SIG' undeclared (first use in this function)
  Keith> acpi.c:462: (Each undeclared identifier is reported only once
  Keith> acpi.c:462: for each function it appears in.)
  Keith> acpi.c:462: `ACPI_SPCRT_SIG_LEN' undeclared (first use in this function)
  Keith> acpi.c:463: `ACPI_DBGPT_SIG' undeclared (first use in this function)
  Keith> acpi.c:463: `ACPI_DBGPT_SIG_LEN' undeclared (first use in this function)
  Keith> acpi.c:404: warning: `madt' might be used uninitialized in this function

Yes, the patch that was mailed to me had the attached hunk missing.
If you apply it, it should compile.

	--david

--- clean/include/asm-ia64/acpi-ext.h	Tue Nov  6 10:21:28 2001
+++ merge/include/asm-ia64/acpi-ext.h	Tue Nov  6 10:48:10 2001
@@ -195,6 +195,12 @@
 #define	ACPI20_ENTRY_PIS_CPEI	3
 #define	ACPI_MAX_PLATFORM_IRQS	4
 
+#define ACPI_SPCRT_SIG	"SPCR"
+#define ACPI_SPCRT_SIG_LEN 4
+
+#define ACPI_DBGPT_SIG	"DBGP"
+#define ACPI_DBGPT_SIG_LEN 4
+
 extern int acpi20_parse(acpi20_rsdp_t *);
 extern int acpi_parse(acpi_rsdp_t *);
 extern const char *acpi_get_sysname (void);

