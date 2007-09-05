From: Robin Holt <holt@sgi.com>
Date: Wed, 05 Sep 2007 13:57:48 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <20070905135748.GB19520@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> No :) those interested are big hardware makers of large scaled out
> boxes, such as HP, UIS. They are using own asics and are not
> necessarily being able to keep chipset native capabilities intact. As
> I said in the preamble, the mechanism has to be there so they can turn
> the ptc.g off and run the OS.

This really sounds like it is best done as a machvec.  Currently, Altix
(sn2) does not have a ptc.g that spans nodes.  We have our own tlb purge
mechanism which is very flexible and scalable.  Maybe it would be best
to follow that example.  To repeat Bjorn's comments, this area can be
fraught with _VERY_ difficult to diagnose problems.  A boot test can
hardly be expected to uncover all the races so be patient while we walk
through this code.

Thanks,
Robin
