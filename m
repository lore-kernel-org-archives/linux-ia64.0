From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 01 Dec 2004 17:03:59 +0000
Subject: Re: [PATCH 2.6.10-rc2] Drop SALINFO_TIMER_DELAY to one minute
Message-Id: <200412010903.59859.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10903.1101872210@kao2.melbourne.sgi.com>
In-Reply-To: <10903.1101872210@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, December 01, 2004 8:44 am, Jack Steiner wrote:
> In your IO code, I think you are probably safe if all you do is clear the
> error. The potential deadlocks are in the logging code. I'm assuming that
> the IO error truely is an error that SHOULD not be logged, right?

In the general case, yes, but in the specific cases I'm worried about, they're 
expected PCI master aborts whose MCAs should be wholly ignored.  So I only 
clear the error if it was entirely recoverable.  If not, the MCA is processed 
normally.

> I agree that the spec really doesn't address MCAs that are usually fatal
> but software managed to ride thru the error. In one sense the error is
> corrected but in another sense it is uncorrected. The spec AFAICT doesn't
> cover this very well.

Yeah, too bad.

Jesse
