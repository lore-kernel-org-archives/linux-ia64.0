From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 08:17:07 +0000
Subject: Re: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 31 Jul 2001 15:36:18 +0900, nomura@hpc.bs1.fc.nec.co.jp said:

  Nomura> To be more precise, on our platform, SAL sets ar.k0 to
  Nomura> 0x80000ffffc000000 for uncached access to
  Nomura> 0xffffc000000.

This isn't right.  There is no way a VA->PA translation can set bit 63
so address 0x80000ffffc000000 could only be generated in physical
mode, which Linux (almost) never uses.  The address 0xffffc000000 is
correct since Linux will access the memory range only through uncached
space (region 6).

	--david

