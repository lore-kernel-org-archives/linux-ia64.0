From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Feb 2004 05:30:31 +0000
Subject: Re: Important NaT-bit bug fix
Message-Id: <16448.10103.128924.316685@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16445.8557.274484.443935@napali.hpl.hp.com>
In-Reply-To: <16445.8557.274484.443935@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 Feb 2004 15:38:15 -0700, dann frazier <dannf@hp.com> said:

  Dann> At what point did the streamlined syscall path go into a
  Dann> 2.4-ia64 release?

It was this patch from about 7 months ago:

http://lia64.bkbits.net:8080/linux-ia64-2.4/diffs/include/asm-ia64/ptrace.h@1.6

which puts it somewhere around 2.4.22.

	--david
