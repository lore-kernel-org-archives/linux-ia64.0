From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Thu, 07 Nov 2002 18:02:38 +0000
Subject: RE: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap
Message-Id: <marc-linux-ia64-105590709805353@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I submitted a problem report on the firmware. Will have to wait and see if
they will make changes.

Thanks for solving our problems. The effort is very much appreciated.

-chuck

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Wednesday, November 06, 2002 8:13 PM
To: Sluder, Charles
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] [PATCH]ACPI fACS global lock & virtual memmap


>>>>> On Wed, 6 Nov 2002 20:52:40 -0600 , "Sluder, Charles"
<Charles.Sluder@UNISYS.com> said:

  Chuck> I tried the patch and it gets rid of the panic.  Before and
  Chuck> after dumps of the memory map are below. The SAL and ACPI
  Chuck> tables are being trimmed from the memory map. That is why the
  Chuck> FACS global lock is mapped uncached. Debug from
  Chuck> acpi_map_os_memory is also include below.

  Chuck> Shouldn't the trim code ignore runtime memory?

No, it can't ignore it.  There is a real problem here: the ACPI table
lies in a 64MB granule which has a hole (because of the missing 4KB
page at 0x000000007ffff000).  Because of that, the kernel simply
cannot safely access that memory via a write-back mapping (the reason
is that the processor prefetch or a speculative load might otherwise
access the hole and MCA while doing that).

So as it stands, Linux simply won't be able to work correctly on a
machine with this kind of memory map.  Can you move the firmware
tables to a granule which is fully populated?

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

