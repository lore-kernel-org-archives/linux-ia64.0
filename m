From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 11 Feb 2004 00:04:35 +0000
Subject: Re: [patch] 2.6.2-rc2 Remove compile warnings from timer.o
Message-Id: <16425.29075.360428.946925@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205061136.GD25002@cse.unsw.EDU.AU>
In-Reply-To: <20040205061136.GD25002@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 11 Feb 2004 10:55:03 +1100, Darren Williams <dsw@gelato.unsw.edu.au> said:

  Darren> I thouht that this might be the case, though the fisrt
  Darren> attempt modified the smallest amount of source.

I'm not sure the new patch is correct.  Shouldn't the values get shifted
left for the case where the shift-amount was formerly negative?

In any case, kernel/timer.c is not an ia64-specific file, so it's best
if you send the patch to the maintainer of that file (with cc to lkml).

Thanks,

	--david
