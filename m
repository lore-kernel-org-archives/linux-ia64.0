From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 07 Nov 2001 01:48:20 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.14)
Message-Id: <marc-linux-ia64-105590698805454@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 5 Nov 2001 22:59:53 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>        linux-2.4.14-ia64-011105.diff*
>	- support non-legacy serial ports via ACPI

Select CONFIG_SERIAL_ACPI, get these errors.

acpi.c: In function `acpi20_parse':
acpi.c:462: `ACPI_SPCRT_SIG' undeclared (first use in this function)
acpi.c:462: (Each undeclared identifier is reported only once
acpi.c:462: for each function it appears in.)
acpi.c:462: `ACPI_SPCRT_SIG_LEN' undeclared (first use in this function)
acpi.c:463: `ACPI_DBGPT_SIG' undeclared (first use in this function)
acpi.c:463: `ACPI_DBGPT_SIG_LEN' undeclared (first use in this function)
acpi.c:404: warning: `madt' might be used uninitialized in this function



