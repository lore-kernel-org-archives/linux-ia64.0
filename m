From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Mar 2003 19:19:08 +0000
Subject: Re: [Linux-ia64] Linux, Itanium and PA/RISC
Message-Id: <marc-linux-ia64-105590723705301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705295@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Mar 2003 12:10:37 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Mon, Mar 24, 2003 at 11:41:18AM +0100, Adriano Galano
  Matthew> wrote:
  >> Hi all:

  >> I read that IA-64 support PA-RISC instruction mapping. That's
  >> mean that I can use Linux for PA/RISC
  >> (http://www.parisc-linux.org/) in a Itanium 2 computer?

  Matthew> No.  You certainly can't run a PA-RISC kernel on an IA64
  Matthew> box, just like you can't run an x86 kernel on an ia64 box.

Ugh, that's not strictly true.  You definitely can boot x86 linux and
windows 98 on Itanium.  I believe the same is true for Itanium 2 if
you have Intel's firmware, though I have never tried that myself.

	--david

