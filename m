From: Paul Mackerras <paulus@samba.org>
Date: Sat, 24 Jan 2004 10:49:26 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for
Message-Id: <16402.19894.686335.695215@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
	<20040120090004.48995f2a.akpm@osdl.org>
	<16401.57298.175645.749468@napali.hpl.hp.com>
In-Reply-To: <16401.57298.175645.749468@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@trained-monkey.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

David Mosberger writes:

> How about something along these lines?  If you want to standardize on
> a single instruction-address format, I'd strongly favor using the
> location-relative addresses used on Alpha and ia64 (it makes no sense
> to uses a full 64-bit address for those members).

Won't you have to change the offset when you move the entry, if the
value you store is relative to the address of the entry?  You could
get around that by storing the offset relative to the start of the
exception table, I guess.

Paul.
