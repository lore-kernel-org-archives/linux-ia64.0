From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 30 Apr 2003 17:33:20 +0000
Subject: RE: [Linux-ia64] benchmarking results
Message-Id: <marc-linux-ia64-105590723705625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705621@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705621@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 30 Apr 2003 18:17:45 +0200, "Adriano Galano" <adriano@satec.es> said:

  Adriano> We need to find some reference of SMP scalability on Linux
  Adriano> scheduler. For 1, 2, 4 and 8 processor. How "lineal" is
  Adriano> this scalability? Does Linux perform well en 4 or 8 Itanium
  Adriano> 2 architecture?

There is no single answer to the scalability question.  It totally
depends on what application you're running.  SGI has shown that
certain apps scale very nicely all the way to 64 CPUs on their Altix
box.  Kernel-intensive apps won't scale that far, but even there there
is some evendice of very nice scaling.  AFAIK, there is only a 4-way
TPC-C number published for Linux:

	rx5670 (4-way 1GHz Itanium 2):	80494 tpmC

but the URL here:

	http://www.hp.com/products1/itanium/performance/commercial/tpcc.html

shows a TPC of about 40600 for a 2-way machine (I believe it was
running Windows).  Given that the 4-way TPC-C number for Windows is in
the same 80k ballpark, it suggests that Linux scales almost linearly
for TPC-C.

  Adriano> Somebody have experience of Linux scalability for more than
  Adriano> 4 Itanium 2 (or Madison) processors?

NEC and SGI already are shipping large Itanium 2 machines.  Not sure
what benchmarks have been run on them with Linux, though.

As far as HP machines are concerned: it's probably best to get in
touch with a sales rep.  He or she should be able to get you more info
on forthcoming machines and perhaps could help you get the application
benchmarked.

	--david

