From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 16 Dec 2004 01:55:59 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151754130.3279@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Wed, 15 Dec 2004, Christoph Lameter wrote:
> 
> Yes that is what my patch does. I am missing the barrier though. Why would
> that be needed?

I just wanted to make sure that the compiler didn't end up re-loading the 
"next" ptr from memory if it had register pressure.

Think of it as another way to say that because we're doing that
speculative thing, we must consider "area->free_list.prev" to be a
volatile access.

		Linus
