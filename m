From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 11 Dec 2001 00:55:48 +0000
Subject: Re: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 10, 2001 at 04:44:42PM -0800, David Mosberger wrote:
> Yes, I realize that, but it's not the CPU that's reordering the access
> so mf doesn't help and mf.a really doesn't guarantee anything either
> (though it may on your platform).

Yeah, that's too bad.  On MIPS we've got 'sync', which is implemented
to do a pio flush.  Apparently IA64 doesn't have a nice way to do
something similiar though, so oh well.

> Invasive, yes.  But on some platforms there may be no other way of
> enforcing order.  Perhaps what would be best would be a macro that
> takes a device address as an argument.  Depending on platform, you
> could then do a dummy read from this address or use a special
> instruction, such as mf.a, to enforce order.

Can you think of other platforms that might need a device argument to
a potential pio barrier macro?  I was tentatively thinking of
implementing it without any arguments, but I suppose we could just
ignore any arguments for our platform...

Thanks,
Jesse

