From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 03 Jun 2004 16:28:52 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406030926420.26108@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Jun 2004, David Mosberger wrote:

> >>>>> On Thu, 20 May 2004 12:05:57 -0700, Christoph Lameter <clameter@sgi.com> said:
>
>   Christoph> The Altix systems never use ITC to determine the time so
>   Christoph> this check and the cmpxchg is not necessary.
>
> I see the problem: the basic problem seems to come from the fact that
> the non-ITC-interpolation code didn't quite come out the way I
> anticipated: I expected even this code to use/need last_nsec_offset
> just like the ITC-based code, but it ended up not doing that.  I
> _think_ that's OK and, if so, we should probably push all the
> last_nsec_offset back down into the interpolator-specific code.
> However, this is tricky code so I want to mull it some more to make
> sure I'm not missing a subtle race.

I also think that pushing that into the interpolators is probably the
right way. I could work on a patch to do that if you do not have time
for it.
