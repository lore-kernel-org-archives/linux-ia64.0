From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Sat, 15 Feb 2003 06:28:09 +0000
Subject: RE: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805859@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks like it might be a problem in EFI.  I traced through BS->GetMemMap()
and the corruption in the returned memory map are left over data in fields
that are not being filled in by the function call.

-chuck



-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Friday, February 14, 2003 12:35 AM
To: eranian@hpl.hp.com
Cc: linux-ia64@linuxia64.org; David Mosberger
Subject: Re: [Linux-ia64] Problem with elilo 3.3a


>>>>> On Thu, 13 Feb 2003 23:28:28 -0800, Stephane Eranian
<eranian@frankl.hpl.hp.com> said:

  Stephane> The bootloader obtains the memory map from EFI. The map is
  Stephane> stored into a region specifically allocated by elilo. The
  Stephane> bootparam structure passes the address of the table and
  Stephane> its size to the kernel.

Ah, that's how I thought it worked.  I misunderstood your previous
mail (on re-reading it, it's clear though... ;-).

Thanks,

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

