From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 17 Jan 2006 22:28:30 +0000
Subject: Re: [PATCH] - Update TLB flushing code for SN platform
Message-Id: <20060117222830.GD13708@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060117222218.GA26725@sgi.com>
In-Reply-To: <20060117222218.GA26725@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 17, 2006 at 04:22:18PM -0600, Jack Steiner wrote:
> This patch only affects the TLB flushing code for SGI SN platforms. No other
> platforms are affected.
> This patch finishes support for SHUB2 (the new chipset). Most of the
> changes are performance related. A few changes are workarounds for
> "interesting" chipset features.
> Some temporary debugging code has also been deleted. 

Very interesting. I'll try this out.


-- wli
