From: "Brent M. Clements" <bclem@rice.edu>
Date: Sat, 12 Apr 2003 16:06:47 +0000
Subject: [Linux-ia64] HPL Benchmark on Itanium 2 box
Message-Id: <marc-linux-ia64-105590723705488@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Guys,
I'm trying to compile the hpl benchmark on a HP zx6000 box.

I have the hp math libraries and the intel 7.0 compilers.

Has anyone ever tried compiling the hpl benchmark using this compile
configuration? If so could they send me their Makefile

The reason I'm asking is because I keep on getting the following error

HPL_pdtest.o: In function `HPL_pdtest':
HPL_pdtest.o(.text+0x1a82): undefined reference to `cblas_dgemv'
HPL_pdtest.o(.text+0x1ad2): undefined reference to `cblas_dgemv'

Anyone have a clue?

Thanks,


Brentr Clements



