From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 19:38:26 +0000
Subject: Re: [PATCH] SAL version is not zero-padded
Message-Id: <16442.22194.388597.274661@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Feb 2004 19:18:57 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> SAL is version 3.1, not 3.01.

-	printk(KERN_INFO "SAL v%x.%02x: oem=%.32s, product=%.32s\n",
+	printk(KERN_INFO "SAL v%x.%x: oem=%.32s, product=%.32s\n",

Eh, it was printing a _byte_.  If you remove the byte-printing, I
suspect you'd also want to switch to a decimal format.

	--david
