From: Cliff Larsen <clarsen@egenera.com>
Date: Thu, 11 Nov 2004 17:12:08 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <1100193128.16960.237.camel@clarsen>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-11-10 at 19:55, Takao Indoh wrote:
> On Wed, 10 Nov 2004 10:53:38 -0500, Philip R Auld wrote:
> >
> >We are still mostly a working with 2.4 (rhel3 which has netdump_func hooks) 
> >and this all worked fine. A crashdump hook, a call to panic, or a call 
> >to BUG each worked.
> 
> Crashdump itself succeeds, but isn't there any problem in analyzing
> dump? Backtrace of "current" on each cpu seem to not work because
> switch_stack is not saved correctly.

We are seeing the same behavior with our 2.4 - we can backtrace all
process but the active.

-- 
Cliff Larsen <clarsen@egenera.com>


