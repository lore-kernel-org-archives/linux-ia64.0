From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 May 2002 19:19:57 +0000
Subject: Re: [Linux-ia64] linux 2.5.17 --- acpi-related hang on boot?
Message-Id: <marc-linux-ia64-105590701905599@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905590@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905590@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 22 May 2002 11:43:36 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, With the small pfn_to_pte patch I sent here last week,
  Peter> Linux 2.5.17 builds and boots on the HP simulator.  But on a
  Peter> real i2000 it hangs during boot.

The problem is due to this patch:

 http://linux.bkbits.net:8080/linux-2.5/diffs/drivers/acpi/acpi_osl.c@1.3?nav=index.html|src/|src/drivers|src/drivers/acpi|hist/drivers/acpi/acpi_osl.c

Changing #if 0 to #if 1 gives me a working kernel (2.5.17).

I haven't had time to look into a proper fix (need to finish the new
TLB flushing code first).

	--david

