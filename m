From: Matthew Wilcox <willy@debian.org>
Date: Fri, 14 Nov 2003 13:11:43 +0000
Subject: Re: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106881558014067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 14, 2003 at 09:45:29AM +1100, Peter Chubb wrote:
> >>>>> "Jesse" = Jesse Barnes <jbarnes@sgi.com> writes:
> 
> Jesse> On Thu, Nov 13, 2003 at 02:51:43PM +0000, Matthew Wilcox wrote:
> >> I'd suggest we want to have defconfig as generic, then add configs/
> 
> Are you planning for separate SMP and UP configs?

I wasn't.  These are only default configs; it's pretty straightforward
to turn an SMP config into a UP config.  Much more simple than maintaining
two configs which differ only in UP vs SMP.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
