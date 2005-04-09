From: Matt Mackall <mpm@selenic.com>
Date: Sat, 09 Apr 2005 00:28:27 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050409002827.GI3174@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 05:21:06PM -0700, David Mosberger wrote:
> Here is a first cut for the patch.  It compiles with gcc 3.3 and 3.4
> and boots on Ski.  Assuming nobody finds any issues, I'll make a final
> patch tonight.

Looks good. Can you verify that /proc/sys/kernel/random/entropy_avail
has sane values in it (eg building up to ~3500 and then slowly
approaching 4096)? random.c now uses fls and fls(0) was causing all
the entropy to vanish.

-- 
Mathematics is the supreme nostalgia of our time.
