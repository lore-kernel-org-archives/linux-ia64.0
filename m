From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 28 Jun 2006 16:50:38 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151513438.15166.41.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
	 <1151483994.3153.5.camel@laptopd505.fenrus.org>
	 <005e01c69ac9$a55e1bf0$6f00a8c0@comcast.net>
	 <1151511668.15166.34.camel@localhost.localdomain>
	 <44A2AA2B.3090101@osdl.org>
In-Reply-To: <44A2AA2B.3090101@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Daiker <jdaiker@osdl.org>
Cc: John Hawkes <hawkes@sgi.com>, Arjan van de Ven <arjan@infradead.org>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

Ar Mer, 2006-06-28 am 09:11 -0700, ysgrifennodd John Daiker: 
> people should have been using the syscall to begin with... we're just 
> forcing it on them this way!  :-)  That's my $0.02

In the cached HZ case there will be no performance hit of measure
anyway. The bigger problem is existing user space. That is why we've
always kept the user visible HZ based values the same when changing the
kernel HZ. You can't automatically regenerate all the old binaries you
might otherwise break.

Performance is only a minor issue, and I doubt anyone who cared about
performance would be using ia-64 anyway

[Grabs coat and exits..]


