From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 08 Jun 2004 05:59:09 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406072253170.17470@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jun 2004, David Mosberger wrote:

> >>>>> On Mon, 7 Jun 2004 21:08:10 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:
>
>   Christoph> Here is the patch with the use of cmpxchg to update
>   Christoph> last_itc:
>
> You're missing my point: if read_seqretry() causes a retry,
> get_offset() better had NOT modified the global time-offset.

It seems that you are not looking at my code and are assuming that the
code is still using last_nsec_offset.

In this implementation get_offset can update "last_itc" however many times
wanted without any problem. last_itc just insures that ITC becomes a
monotonic clock like the other clock sources. last_nsec_offset is not
used and could be removed.
