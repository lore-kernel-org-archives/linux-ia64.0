From: Keith Owens <kaos@sgi.com>
Date: Tue, 11 May 2004 11:32:00 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <4734.1084275120@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 11 May 2004 00:03:55 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 07 May 2004 18:12:49 +1000, Keith Owens <kaos@sgi.com> said:
>
>  Keith> On Wed, 5 May 2004 20:42:24 -0700, David Mosberger
>  Keith> <davidm@napali.hpl.hp.com> wrote:
>
>  >> I considered that approach but rejected it because it runs the
>  >> "FORTRAN constant" risk.  That is, someone might write to a saved
>  >> register (e.g., via unw_set_br()) and end up inadvertently
>  >> redefining the 0 "constant" (unw_r0) to a non-zero value.
>
>  >> Perhaps what we could do is change unw_access_{gr,br,fr,ar,pr} to
>  >> reject attempts to write to the special save-address &unw_r0.  I
>  >> think that would make it safe.
>
>  Keith> Unlikely, but if that is what it takes ....
>
>Can you try what's in the current bk repository?  It closely follows
>your patch, apart from some naming and from switching the asm files to
>actually use ".save rp, r0".

I don't have bk access.  Where's the patch?

