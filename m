From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Apr 2004 05:19:47 +0000
Subject: RE: Questions on the stack for IA64
Message-Id: <16508.51699.368241.279836@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Apr 2004 22:05:56 -0700 (PDT), Rahul Chaturvedi <justanotheraliasforrahul@yahoo.com> said:

  Rahul> Does the compiler ever touch this backing store?

Not directly.

  Rahul> I believe it is used during a stack unwind?

Yes (as is the memory stack and the registers).

  Rahul>         printf("", a, b, c, d, e, f, g, h, i, j, k, l, m, n,
  Rahul> o, p, q, r, s, t, u, v, w, x, y, z, aa, bb, cc, dd, ee, ff,
  Rahul> gg);

  Rahul> As you can see, almost all the parameters are being "st4'd"
  Rahul> to memory. From the architecture specification, shouldn't all
  Rahul> these be moved into registers? I have a total of much lesser
  Rahul> than 96 parameters?

You need to look at the software conventions & runtime architecture guide:

  http://www.intel.com/design/itanium/downloads/245358.htm

It specifies that up to 8 registers are used for argument passing.

There are also some fine books that might help you get started. ;-)

	--david
--
Interested in learning more about IA-64 Linux?  Try http://www.lia64.org/book/
