From: Matthew Wilcox <willy@debian.org>
Date: Wed, 08 Oct 2003 11:47:39 +0000
Subject: Re: Why does salinfo_log_read_cpu use kmalloc?
Message-Id: <marc-linux-ia64-106561367122797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106559698807998@msgid-missing>
In-Reply-To: <marc-linux-ia64-106559698807998@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 08, 2003 at 05:08:14PM +1000, Keith Owens wrote:
> Why does arch/ia64/kernel/salinfo.c::salinfo_log_read_cpu() use
> kmalloc() for the log buffer?  The code is running virtual with
> interrupts enabled, SAL_GET_STATE_INFO has no special requirements for
> the buffer attributes, so why not use vmalloc()?

I don't see a function called salinfo_log_read_cpu in
arch/ia64/kernel/salinfo.c ... moreover, I don't see any occurrences of
the string "alloc" in that file.  Sure you're looking at the right tree?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
