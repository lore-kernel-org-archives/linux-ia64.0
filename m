From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 22:09:29 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16447.49177.612592.683747@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 Feb 2004 13:48:50 -0800, "Randy.Dunlap" <rddunlap@osdl.org> said:

  Randy> Where's the trigraph???

Thanks, you just saved me some typing... ;-)
(Trigraphs are a really ugly way to type curly braces and stuff like
that for people who have keyboards without a curly brace key etc.)

  Randy> A conditional operator ("?:") [section 6.5.15 of C99 spec.]
  Randy> does not make a 'trigraph'.

  Randy> Conditional operators are fine IMO, so long as the gcc
  Randy> extension of "omitted second operand implies repeat the first
  Randy> operand" is not used... :) This is ugly and prone to
  Randy> mistakes.

Agreed.  The patched looked perfectly fine to me.

	--david
