From: Andrew Morton <akpm@osdl.org>
Date: Fri, 17 Oct 2003 22:50:28 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106643118916896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>
> Old behavior:
> 
>     # dd if=/dev/mem of=/dev/null
>     <unrecoverable machine check>

I recently fixed this for ia32 by changing copy_to_user() to not oops if
the source address generated a fault.  Similarly copy_from_user() returns
an error if the destination generates a fault.

In other words: drivers/char/mem.c requires that the architecture's
copy_*_user() functions correctly handle faults on either the source or
dest of the copy.

