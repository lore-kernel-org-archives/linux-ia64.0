From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 15 Feb 2005 20:15:19 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050215201519.GA13009@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Feb 2005 13:31:48 -0600, Robin Holt <holt@sgi.com> said:
Robin> Is there a strong objection to implementing 4 levels of 16k
Robin> page tables for now and then, if someone else sees a need,
Robin> convert to using long page table format and adjust page
Robin> tables as needed at that point in time.

On Tue, Feb 15, 2005 at 11:46:21AM -0800, David Mosberger wrote:
> I certainly don't want to switch my machines to 4-levels.  There is
> zero need for that on the machines I use, so why pay the overhead of
> an extra level?
> BTW: why do you want 4-level/16KB over 3-level/64KB?

It may be worth noticing that things like fault latency and small
writes degrade with increased pagesize, though I seem to recall hearing
that this effect was less pronounced or did not set in at 64KB on ia64.


-- wli
