From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Dec 2005 00:19:22 +0000
Subject: Re: Reading /proc/stat is slooow
Message-Id: <20051206001922.GA4920@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 06, 2005 at 12:36:20AM +0100, Andreas Schwab wrote:
> About 20 miliseconds, ten times of what I see with 2.6.13.  It appears to
> be that the generation of /proc/stat doesn't scale well any more with the
> number of configured CPUs (CONFIG_NR_CPUS is 512 here).  Processes that
> monitor /proc/stat add a significant amount of load to the system.

I just tried CONFIG_NR_CPUS24 ... and I don't see anything
like a 20ms delay on 2.6.15-rc5.  How many actual cpus on your
machine (I only have two on the machine where I tested)?

-Tony
