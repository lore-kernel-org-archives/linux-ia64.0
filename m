From: Pete Zaitcev <zaitcev@redhat.com>
Date: Mon, 11 Feb 2002 20:57:49 +0000
Subject: [Linux-ia64] Re: driver location for platform-specific drivers
Message-Id: <marc-linux-ia64-105590698806033@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For SGI's upcoming Linux platform (nicknamed Scalable Node, or SN),
> we have some platform specific device drivers.  Where should these go?

>     1) Integrate in drivers/*.

I'd do this, unless you have dozens of them.
E.g. drivers/net/sunhme.c.

>     2) Company (sgi) directory.

That's nonsense, IMHO.

>     3) New platform directory.
>        Create a platform directory for SN, probably drivers/sn.
>        There is precedence for this with the drivers/macintosh
>        and drivers/s390.

I think this is only done if API is different. Often these
directories cannot be processed by a build process on other
architectures, so they are kept outside to have Makefiles smaller.
See also drivers/sbus, which could be called "drivers/sun" just
as well. But really, it's separate because of sparc_alloc_io().

I appreciate a lot that drivers/acpi is so easy to exclude
from builds - it breaks on anything but Intel stuff.

>     4) New architecture directory.
>        Another suggestion is to create an architecture directory,
>        in this case drivers/ia64/{char,net,etc.}/.

See #3. The ia64 uses standard APIs.

> I'm happy with whatever you'll accept.

Yeah, lessee what penguins say, and also I think DaveM may
lend some good expirience here.

-- Pete

