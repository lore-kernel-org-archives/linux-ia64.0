From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 May 2004 05:10:24 +0000
Subject: Re: Kill warnings in 2.6.6
Message-Id: <16556.15808.385172.779090@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 May 2004 14:55:06 +1000, Peter Chubb <peterc@gelato.unsw.edu.au> said:

  David> Where does this get rid of a warning?  A driver or something
  David> else?

  Peter> If you configure with GENERIC, then asm/machvec.h is included
  Peter> which has declarations for struct device, etc, but without
  Peter> GENERIC the definitions are missing.

Ah, that explains why I didn't see the warnings: I had already fixed
them by including machvec.h in machvec.c.

Thanks,

	--david
