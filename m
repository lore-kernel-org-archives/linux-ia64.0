From: Matt Mackall <mpm@selenic.com>
Date: Fri, 08 Apr 2005 23:17:02 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050408231702.GG3174@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 04:02:15PM -0700, Luck, Tony wrote:
> >So there's the off-by-one problem. And then there's the huge
> >discontinuity at 0. Trouble is the bias is 65535 rather than 65536 so
> >there's no masking trick that works. We could instead to do
> >exp((x*2)+1).
> 
> That will fail for x=0x8000000000000000 ... returns '1' instead of '64'.

That's ok, the function we actually need to fix is fls(int), not
ia64_fls(unsigned long).

-- 
Mathematics is the supreme nostalgia of our time.
