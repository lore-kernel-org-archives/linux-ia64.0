From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 May 2005 20:34:10 +0000
Subject: RE: heads up: apparent GAS bug in current (CVS) binutils
Message-Id: <17029.3906.33841.302589@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
In-Reply-To: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 May 2005 10:32:19 -0700, "Lu, Hongjiu" <hongjiu.lu@intel.com> said:

  HJ> I tried binutils 2.15.92.0.2 20040927 and got the same
  HJ> result. What is the version of assembler which you think is
  HJ> good?

The standard Debian/sarge as seems fine:

 $ as -v
 GNU assembler version 2.15 (ia64-linux) using BFD version 2.15

	--david
