From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Feb 2003 07:34:54 +0000
Subject: Re: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Feb 2003 23:28:28 -0800, Stephane Eranian <eranian@frankl.hpl.hp.com> said:

  Stephane> The bootloader obtains the memory map from EFI. The map is
  Stephane> stored into a region specifically allocated by elilo. The
  Stephane> bootparam structure passes the address of the table and
  Stephane> its size to the kernel.

Ah, that's how I thought it worked.  I misunderstood your previous
mail (on re-reading it, it's clear though... ;-).

Thanks,

	--david

