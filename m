From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 13 Oct 2004 17:29:02 +0000
Subject: Re: Periodic posix timer support broke between 2.6.9-rc1 and
Message-Id: <Pine.LNX.4.58.0410131027390.9734@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0410130902490.9272@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0410130902490.9272@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Oct 2004, George Anzinger wrote:

> The most likely thing would be failure to do the call back from the signal
> delivery code.

The problem was my setting of the resolution of CLOCK_REALTIME and
CLOCK_MONOTONIC to the resolution of the time interpolator. That screwed
up interval calculation. Fix was submitted to Andrew and Linus and will
hopefully get into 2.6.9 final.


