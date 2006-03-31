From: Andi Kleen <ak@suse.de>
Date: Fri, 31 Mar 2006 16:00:19 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <200603311800.19364.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net>
In-Reply-To: <yq0sloytyj5.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Friday 31 March 2006 17:38, Jes Sorensen wrote:
> Hi,
> 
> Patch 70674f95c0a2ea694d5c39f4e514f538a09be36f
>   [PATCH] Optimize select/poll by putting small data sets on the stack
> resulted in the poll stack being 4-byte aligned on 64-bit
> architectures, causing misaligned accesses to elements in the array.
> 
> This patch fixes it by declaring the stack in terms of 'long' instead
> of 'char'.

You should do that for poll too then.

-Andi
