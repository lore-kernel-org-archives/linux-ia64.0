From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 19 Sep 2005 18:10:40 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <ed5aea4305091911105512fcb@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/19/05, Christoph Lameter <clameter@engr.sgi.com> wrote:

> However, any mechanism like that will have a time running strangely fast
> for awhile which may cause other subsystems to misbehave.

That's already true due to NTP.

> I still think that the proposed patch is the best compromise solution
> since it restored the normal flow of time as soon as possible.

I disagree.  Time jumps are much worse than making time go slightly
faster/slower for a period of time.  What's even better, the timeouts
you're seeing when making time jump almost certainly will just
disappear, which is extremely nice.

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
