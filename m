From: Christoph Lameter <christoph@lameter.com>
Date: Tue, 08 Jun 2004 18:32:46 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406081129420.14920@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 8 Jun 2004, David Mosberger wrote:
> >>>>> On Tue, 8 Jun 2004 00:11:25 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:
>
>   Christoph> How could this implementation put a bogus value into
>   Christoph> last_itc?
>
> The itc_get_offset() calculation depends on TIME_KEEPER->itm_next,
> "jiffies" and "wall_jiffies", all of which are updated asynchronously
> in response to a timer-interrupt.  If a timer-interrupt hits while
> itc_get_offset() is running, the resulting value may have used
> inconsistent values for those variables and hence could be bogus.

This does not effect the update of last_itc which does not depend on
any of the variables you mention. The dependency existed for
last_nsec_offset but does NOT exist for last_itc. There is much more than
just a name change going on.

The bogus return value from get_offset will be ignored by gettimeofday
because of the seqlock. That aspect of get_offset is the same as before.


