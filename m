From: Matthew Wilcox <willy@debian.org>
Date: Wed, 19 Nov 2003 20:20:20 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927324202872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 19, 2003 at 12:11:03PM -0800, David Mosberger wrote:
> >>>>> On Wed, 19 Nov 2003 19:54:02 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> This is the same thing as printing the user unaligned
>   Matthew> exceptions.  It's something no other architecture does, and
>   Matthew> for a reason, which has been explained to you before, but
>   Matthew> you don't want to fix it.
> 
> And yet both features are incredibly useful when debugging, something
> you seem to ignore.

No, it *isn't*.  The majority of systems in use are not being debugged
(regardless of how you & I spend most of our time).  Having these
messages constantly stream past in dmesg (which no other architecture
does) serves only to potentially mask other, useful pieces of information
and confuse the customer.

Every time we emit something to the system log, it's a potential support
call.  Our friends in other parts of HP are already unhappy with how much
output Linux produces even when everything's OK.  It's also a sysadmin
hassle as logfiles fill up more quickly when this kind of junk goes by.

I'm sure this was useful for debugging once, but those days are gone.
We need to print less of this stuff.  Something a lot of places do is:

#undef DEBUG

#ifdef DEBUG
#define DBG(x...) printk(x)
#else
#define DBG(x...)
#endif

Would it mollify you if these printks were turned into DBGs?

Or perhaps better, we could use pr_debug() from <linux/kernel.h>.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
