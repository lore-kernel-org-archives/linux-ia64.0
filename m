From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 24 Jan 2003 16:03:19 +0000
Subject: Re: [Linux-ia64] Epca patches
Message-Id: <marc-linux-ia64-105590709805746@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805740@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805740@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Agree that all the modifications are not ia64-specific.
> However, some of them are 64 bits specific and are related to 64 port:
>   - struct board_chan (digiFep1.h, describes a fragment of I/O memory space
>     shared between driver and firmware) must be of 128 bytes long exactly.
>   - driver's data definitions and insmod MODULE_PARM declarations
>     must be consistent.
>   - ioremapped memory base addresses data must be long (64 bits).
>   - epca module in the kernel sources is not 64 bits
>     epca.c
>       #if BITS_PER_LONG != 32
>       #  error FIXME: this driver only works on 32-bit platforms
>       #endif

The point is, the epca driver has a maintainer.  Changes to it
should go through him.

All the changes you mention can be made in a way that will work
on both 32-bit and 64-bit platforms.  And they can almost certainly
be done without all the ugly IA64 #ifdefs.  If you head in that
direction, I suspect that the maintainer will be interested in
your changes.

Bjorn


