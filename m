From: Simon Horman <horms@verge.net.au>
Date: Tue, 29 Jul 2008 23:18:42 +0000
Subject: Re: Regression on ia64 with cpu masks: optimize and clean up
Message-Id: <20080729231842.GH6370@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729034459.GA11699@verge.net.au> <20080729095001.GA509@verge.net.au> <488F3832.8010007@sgi.com>
In-Reply-To: <488F3832.8010007@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Travis <travis@sgi.com>
Cc: Linux-kernel <Linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>

On Tue, Jul 29, 2008 at 08:33:06AM -0700, Mike Travis wrote:
> Check linux-next, I believe the exact same fix is in there.  Apparently,
> as Stephen and others have pointed out earlier, that syntax isn't evaluated 
> correctly in earlier gcc's (at least earlier then the 4. series).

Thanks, confirmed.

dde108a23e4bf6d6d225ae18c64abeaf85fe2b50 in linux-next includes
the same fix that I stumbled upon.

-- 
Horms

