From: Andi Kleen <ak@suse.de>
Date: Wed, 17 Aug 2005 00:11:44 +0000
Subject: Re: [PATCH] Fix gcc 4 warnings on ia64
Message-Id: <20050817001144.GA3996@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816155747.GN20749@wotan.suse.de>
In-Reply-To: <20050816155747.GN20749@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 16, 2005 at 05:05:42PM -0700, Luck, Tony wrote:
> 
> > You actually need the const attribute on __ia64_get_io_port_base
> 
> cscope didn't show any users of this function ... so I thought
> perhaps the callers were in some macros that concatenated
> strings with ## to make the name, but I couldn't see any.

You also need to fix the other function which had a bogus volatile.

BTW I bet the rationale in mmu.h for the volatile is bogus.

-Andi
