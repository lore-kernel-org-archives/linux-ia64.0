From: Grant Grundler <iod00d@hp.com>
Date: Wed, 29 Mar 2006 01:44:40 +0000
Subject: Re: Add full memory fence for test_and_*_bit operation
Message-Id: <20060329014440.GE26920@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603290048.k2T0mmg32601@unix-os.sc.intel.com>
In-Reply-To: <200603290048.k2T0mmg32601@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 28, 2006 at 04:49:24PM -0800, Chen, Kenneth W wrote:
> OK, semi-big-hammer to enforce full memory fence on ia64 for
> test_and_set_bit
> test_and_clear_bit
> test_and_change_bit
> 
> It's sad we don't have something like:
> 
> test_and_set_bit_used_like_a_lock
...

Normally the arch specific (e.g. __set_bit or __raw_readl) provide
different semantics than the "portable" versions (e.g set_bit and readl).
Can folks who know what they are doing can use arch specific versions
at the expense of portability?

I expect the driver to compile and work correctly on all arches,
it will just be a bit more of a PITA to maintain.

grant
