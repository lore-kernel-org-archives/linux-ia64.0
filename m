From: Matt Mackall <mpm@selenic.com>
Date: Thu, 10 Mar 2005 19:36:11 +0000
Subject: Re: [PATCH] silence sort(..., swap) warning on ia64
Message-Id: <20050310193611.GL3120@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050310181835.GA8348@taniwha.stupidest.org>
In-Reply-To: <20050310181835.GA8348@taniwha.stupidest.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Wedgwood <cw@f00f.org>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 10, 2005 at 10:18:35AM -0800, Chris Wedgwood wrote:
> Not tested but seems plausible :-)

Yep, this was pointed out to me yesterday.
  
> -static void swap_ex(void *a, void *b)
> +static void swap_ex(void *a, void *b, int _unused_size)

-- 
Mathematics is the supreme nostalgia of our time.
