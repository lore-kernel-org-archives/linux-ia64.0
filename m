From: Christoph Lameter <christoph@lameter.com>
Date: Tue, 08 Jun 2004 07:11:25 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406080008210.5817@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jun 2004, David Mosberger wrote:

>   Christoph> In this implementation get_offset can update "last_itc"
>   Christoph> however many times wanted without any problem. last_itc
>   Christoph> just insures that ITC becomes a monotonic clock like the
>   Christoph> other clock sources. last_nsec_offset is not used and
>   Christoph> could be removed.
>
> It doesn't matter what you're calling the variable.  If you update a
> global variable with a bogus value, you lose.  Sure, it will be
> monotonic, but if you get unlucky and the (bad) interpolated value
> jumped forward by a huge amount, you'll get horrible resolution for a
> long time to come.

How could this implementation put a bogus value into last_itc?

