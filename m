From: Matthew Wilcox <willy@debian.org>
Date: Tue, 04 Jun 2002 12:02:41 +0000
Subject: Re: [Linux-ia64] Question about wbinvd
Message-Id: <marc-linux-ia64-105590701905636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 04, 2002 at 04:45:42PM +0900, Takanori Kawano wrote:
> I have a question about wbinvd in acpi code.
> 
> In 2.4.18, wbinvd is implemented in drivers/acpi/include/platform/acgcc.h
>  as follows.

If you look at the latest ACPI patch (20020517), you will see:

-       wbinvd();
+       ACPI_FLUSH_CPU_CACHE ();

On i386, ACPI_FLUSH_CPU_CACHE is defined to be wbinvd, but on ia64 it is
defined to be a no-op.  So the wbinvd in the ACPI code is no longer used.
I presume it was decided it is not necessary.

-- 
Revolutions do not require corporate support.

