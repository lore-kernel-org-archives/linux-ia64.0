From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Tue, 25 Apr 2006 14:46:03 +0000
Subject: Re: I/O read, write implementation questions
Message-Id: <ed5aea430604250746v3e5935bat7c4a9e97377ed0f7@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444E2EA6.8000604@bull.net>
In-Reply-To: <444E2EA6.8000604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan,

On 4/25/06, Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:
> The SDM shows on pages 2:585-586 how the I/O space reads and
> writes have to be iplemented, e.g.:
>
> outb:   ...
>         mf
>         st1.rel [port_addr] = in1
>         mf.a
>         mf
>
> inb:    ...
>         mf
>         ld1.acq r8 = [port_addr]
>         mf.a
>         mf
>
> The actual implementation does not include the pairs of "mf"-s.
> Can someone, please, explain me why they are left off?

Linux itself supports weak memory ordering.  You want to minimize the
amount of fences in low-level primitives because they're expensive and
you only want to pay the prize of them when they're really needed.

> The following code sequence:
>
>         outb(data, port_addr);
>         flag = 1;
>
> may be compiled as:
>
>         add     r8 = 1, r0
>         add     r2 = flag_offs, r1
>         ;;
>         st1.rel [port_addr] = data
>         mf.a
>         st1     [r2] = r8
>
> What prevents "st1 [r2] = r8" from being seen before
> "st1.rel [port_addr] = data" is seen?

Nothing.  Why *should* an unordered store be ordered with respect to
outb()?  If you want ordering, either declare "flag" volatile or add
an explicit barrier.

> Why do not "readb()" ... "writeb()" include "mf.a"-s?

Again, acceptance is not normally needed by readX/writeX and mf.a is
extremely expensive (on the order of 1,000 cycles).  If you want
ordering, you need to use explicit barriers (or rely on the effect of
"volatile" in ia64-specific code).

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
