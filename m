From: "Raj Pati" <rpatil0299@hotmail.com>
Date: Mon, 22 Mar 2004 22:09:28 +0000
Subject: RE: Question about ia64 linux
Message-Id: <BAY14-F35qHSKGIlB7C000002c4@hotmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAY14-F301ImxoKYUVs0007e432@hotmail.com>
In-Reply-To: <BAY14-F301ImxoKYUVs0007e432@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Thanks for the comments/pointers Tony.

Regards,
Raj


>From: "Luck, Tony" <tony.luck@intel.com>
>To: "Raj Pati" <rpatil0299@hotmail.com>, <linux-ia64@vger.kernel.org>
>Subject: RE: Question about ia64 linux
>Date: Sun, 21 Mar 2004 22:13:23 -0800
>
> >Is it possible to modify a running code (in a module or kernel)
> >in ia64 linux? (It is not a good practise to do it.
> >But, I need to check  this out as it was done in ia32.....)
>
>Yes it can be done.  Whether it is good practice is in the
>eye of the beholder ... and depends a lot on what you are
>actually doing.  If you have some 1950's code that reads
>auccessive elements from an array my modifying the code that
>loads the address ... then it's time to rewrite :-)  If you
>have some on-the-fly code generation (e.g. a Just-in-time
>compilation system) ... then that's a lot more palatable.
>
> >Probably, it is possible. I just wanted to see whether
> >there are any issues one should be aware of other than
> >serialization/flushing. There are couple of pages of
> >documentation regarding self-modifying code in one of
> >the ia64 software developers manual. I am curious
> >whether there are any other notes/writeups or sample
> >code where similar kind of things are done in ia64
> >linux.  I really appreciate if some one can direct me
> >to such doc or code (if they exist) which can give
> >some more ia64  specific information.
>
>The software developers manual covers everything that
>you need to know.  There are some code examples in the
>Linux kernel code (where we modify a load instruction
>to grab the physical address of an object, rather than
>the virtual address ... used because the address won't
>be known for sure until run-time).  These aren't very dynamic
>though ... the instructions are patched during kernel
>initialization, and never touched again. Look at
>ia64_patch_vtop() in arch/kernel/ia64/patch.c
>
>-Tony

_________________________________________________________________
FREE pop-up blocking with the new MSN Toolbar =96 get it now!=20
http://clk.atdmt.com/AVE/go/onm00200415ave/direct/01/

