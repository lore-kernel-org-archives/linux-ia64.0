From: Paul Mackerras <paulus@samba.org>
Date: Tue, 27 Jan 2004 08:56:26 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for
Message-Id: <16406.10170.911012.262682@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
	<20040120090004.48995f2a.akpm@osdl.org>
	<16401.57298.175645.749468@napali.hpl.hp.com>
	<16402.19894.686335.695215@cargo.ozlabs.ibm.com>
	<16405.41953.344071.456754@napali.hpl.hp.com>
In-Reply-To: <16405.41953.344071.456754@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@trained-monkey.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

David Mosberger writes:

> How about the attached one?  It will touch memory more when moving an
> element down, but we're talking about exception tables here, and I
> don't think module loading time would be affected in any noticable
> fashion.

Hmmm...  Stylistically I much prefer to pick up the new element,
move the others up and just drop the new element in where it should
go, rather than doing swap, swap, swap down the list.

Also, I don't think there is enough code there to be worth the bother
of trying to abstract the generic routine so you can plug in different
compare and move-element routines.  The whole sort routine is only 16
lines of code, after all.  Why not just have an ia64-specific version
of sort_extable?  That's what I thought you would do.

Regards,
Paul.
