From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 01 Sep 2004 07:39:11 +0000
Subject: Re: [1/1] make bad_page() print all of page->flags
Message-Id: <20040901073911.GY5492@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040901061443.GW5492@holomorphy.com>
In-Reply-To: <20040901061443.GW5492@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 31, 2004 at 11:14:43PM -0700, William Lee Irwin III wrote:
>> (1) is this struct page actually in your virtual mem_map?

On Wed, Sep 01, 2004 at 05:28:17PM +1000, Ian Wienand wrote:
> I'm assuming so, since when it's turned off it works?

That's not quite enough to tell. Generally some kind of dump of the
index of the sparse array (probably the ptes mapping it) so that the
virtual addresses falling within it can be detected is needed to tell.


On Tue, Aug 31, 2004 at 11:14:43PM -0700, William Lee Irwin III wrote:
>> (2) page->flags looks 32-bit, but ia64 doesn't define
>> 	ARCH_HAS_ATOMIC_UNSIGNED that I can tell; what's going on there?
>> 	Let's see if those flags are really all zero.

On Wed, Sep 01, 2004 at 05:28:17PM +1000, Ian Wienand wrote:
> Thanks, I applied the patch and it seems to be all zeros
> Bad page state at free_hot_cold_page (in process 'swapper', page e000000004940c98)
> flags:0x0000000000000000 mapping:0000000000000000 mapcount:1 count:0
> Backtrace:
> [-- stops again --]

My bet is that this is not a real page, or otherwise that it's
uninitialized and some kind of boundary conditions in
free_area_init_core() or surrounding functions have been flubbed.


On Tue, Aug 31, 2004 at 11:14:43PM -0700, William Lee Irwin III wrote:
>> (3) "stops dead" isn't a very good description; deadlock? livelock?
>> 	interrupts on or off?

On Wed, Sep 01, 2004 at 05:28:17PM +1000, Ian Wienand wrote:
> It doesn't respond to magic-sysrq and I guess it takes an MCA because
> it spontaneously reboots after about 10 seconds, though doesn't print
> anything useful before it does that.

"Fatal machine check" sounds like a good description of this.


-- wli
