From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 16 Jul 2004 00:11:41 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040716001141.GA3411@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 04:16:38PM -0700, William Lee Irwin III wrote:
>> Unfortunately no. It would be nice to have one.

On Fri, Jul 16, 2004 at 12:34:20AM +0100, Matthew Wilcox wrote:
> #define log2(x) (ffs(x) - 1)
> (ffs returns a value from 0 to 32 whereas log2 wants to return -1 to 31)
> Obviously it rounds down, but that's entirely consistent with the behaviour
> of, say, 7/4 in C.

The kernel uses __ffs(), which returns from 0 to 31 and is undefined on 0.
Its rounding behavior is wrong for log2(). Anyhow, we happen to know it's
a power of 2 and that __ffs() will do.


-- wli
