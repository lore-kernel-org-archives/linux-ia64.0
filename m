From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Mar 2004 00:09:04 +0000
Subject: Re: [patch] 2.4.25 sync unwind code with 2.6.3
Message-Id: <16454.29600.232779.817787@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3792.1077504388@kao2.melbourne.sgi.com>
In-Reply-To: <3792.1077504388@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 3 Mar 2004 16:53:36 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

 > -                       val = unw.preg_index[UNW_REG_F2  + (rval -  1)];
 > +                       val = unw.preg_index[UNW_REG_F2  + (rval -  2)];

 > You didn't change this, but I'd feel better if I understood
 > why this is different.

It was a typo.  The code is needed to handle f2-f5, hence the "- 2".

	--david
