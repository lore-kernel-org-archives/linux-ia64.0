From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 07 Jun 2004 17:46:41 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406071041270.2844@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Would it be possible to avoid any changes to arch independent code by
changing get_offset fir the ITC clock to never return an earlier offset in
the same tick?

Then the ITC specific code in the gettimeofday could be removed.

There is a use of volatile that be better avoided (I think the general
recommendation on l-k is to use barriers). The fieldname "is_drifty" can
lead to misunderstandings since drift is typically used to refer to
continual drift due to inaccuracies of the clocks and not because a
variety of clocks are in use.

On Fri, 4 Jun 2004, David Mosberger wrote:

> >>>>> On Thu, 20 May 2004 12:05:57 -0700, Christoph Lameter <clameter@sgi.com> said:
>
>   Christoph> The Altix systems use a global clock as the time source
>   Christoph> for gettimeofday and not the ITC.  In do_gettimeofday() a
>   Christoph> cmpxchg instruction is used to insure that ITC based time
>   Christoph> calculations never return an earlier time.  This cmpxchg
>   Christoph> seems to be the reason for the scalability issues.
>
> How does the attached look/work for you?
