From: Tony Luck <tony.luck@gmail.com>
Date: Sat, 08 Oct 2005 02:40:54 +0000
Subject: Re: [Fwd: Weird ia64 problem]
Message-Id: <12c511ca0510071940m3e1278d9vb2f708c65aa43cc3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'm thinking it should check if (PIPE_SIZE - buf->len) > PIPE_BUF, and
> set do_wakeup.  The code could be #defined out if PIPE_SIZE = PIPE_BUF,
> so the change reduces to a no-op on other archs.
>
> Does that sound right?  I'm going to work on a patch here.

Roughly (without looking back as fs/pipe.c).  When you have your
patch, you will need to restart this discussion on the linux-kernel
mailing list (since you'll be touching a generic file).  Some random
grepping for PAGE_SIZE (well PAGE_SHIFT) shows that some
other artchitectures have some support for page size > PIPE_BUF.
So there should be some interest in this fix.

-Tony
