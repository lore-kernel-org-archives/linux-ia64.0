From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 13 Mar 2002 05:32:39 +0000
Subject: Re: [Linux-ia64] Exception handling and recovery
Message-Id: <marc-linux-ia64-105590701905254@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Mar 2002 16:22:45 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Exactly.  IMHO ia64_fault should always
  Keith> search_exception_table(), even if kdb is not installed.
  Keith> Other architectures use exception tables to detect if the
  Keith> hardware supports extra instructions, registers, MSR values

IA-64 has CPUID, PAL, SAL, and ACPI for such purposes.

  Keith> etc., exception recovery should be general purpose.

Generality for the sake of generality only results in bloat.  The
exception handling should be used where it makes sense.  Outside of
debugging, there is no good reason to search the exception tables in
ia64_fault().  In fact, it might only end up hiding real kernel bugs.

	--david

