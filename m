From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 13 Jul 2005 03:45:03 +0000
Subject: Re: autocompilation hosed?
Message-Id: <12c511ca0507122045279fbc32@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'm also using gcc-4.0.1 by default now.  It basically seems to work
> (apart from lots of additional annoying warning messages).  There is
> one oddity: on my zx2000, it doesn't boot anymore without console=tty0
> or console=ttyS0 arguments.  I'm not sure yet whether that's a
> compiler-triggered problem or whether something changed in the kernel
> that's causing this.

No ... I saw it too without gcc-4.  See http://tinyurl.com/clzbu where I
identified the patch that seems to be the cause.

-Tony
