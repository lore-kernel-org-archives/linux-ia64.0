From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Nov 2002 23:35:21 +0000
Subject: Re: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Nov 2002 15:31:21 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> Yes, this clearly seems to be a bug in the ACPI code.  It's
  David> wrong to use the "m" constraint there.  Can you send to is
  David> patch to Andy Grover as well so it gets into ACPI mainline?

Oops, never mind.  I thought the offending file was in the
drivers/acpi subtree.  Since it's in asm-ia64/acpi.h, I can fix it.

Thanks,

	--david

