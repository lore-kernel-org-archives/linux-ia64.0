From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Oct 2003 12:48:06 +0000
Subject: Re: Why does salinfo_log_read_cpu use kmalloc?
Message-Id: <marc-linux-ia64-106561753626820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106559698807998@msgid-missing>
In-Reply-To: <marc-linux-ia64-106559698807998@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Oct 2003 12:47:39 +0100, 
Matthew Wilcox <willy@debian.org> wrote:
>On Wed, Oct 08, 2003 at 05:08:14PM +1000, Keith Owens wrote:
>> Why does arch/ia64/kernel/salinfo.c::salinfo_log_read_cpu() use
>> kmalloc() for the log buffer?  The code is running virtual with
>> interrupts enabled, SAL_GET_STATE_INFO has no special requirements for
>> the buffer attributes, so why not use vmalloc()?
>
>I don't see a function called salinfo_log_read_cpu in
>arch/ia64/kernel/salinfo.c ... moreover, I don't see any occurrences of
>the string "alloc" in that file.  Sure you're looking at the right tree?

2.4.22-ia64-030909 and 2.4.22 pristine.  For some reason, this code is
not in the 2.6 trees.

