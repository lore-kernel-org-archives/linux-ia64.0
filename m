From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 30 Jul 2004 15:34:56 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <Pine.LNX.4.58.0407300831280.7250@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 30 Jul 2004, Jack Steiner wrote:

> The new code certainly is faster, but does it scale at high cpu counts?
>
> The numbers above indicate a substantial slowdown going from 1 to 2
> cpus. What happens at higher cpu counts.

The code that uses cmpxchg will always be a scalability issue. There is no
slowdown if that is switched off (nojitter option for ITC based systems)
which can be done for most systems.

For SN2 systems the cmpxchg is never used and therefore
there is barely any scalability issues (See the numbers posted for the
version 6 patch). I will try to increase the scalability
for systems needing the cmpxchg (large ITC offsets) but frankly I do
not see much hope for major improvements beyond what David already
accomplished with the old routine.
