From: Don Dugger <n0ano@valinux.com>
Date: Fri, 27 Oct 2000 16:51:57 +0000
Subject: Re: [Linux-ia64] Common kernel paging error I get
Message-Id: <marc-linux-ia64-105590678205638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken-

What it is is most likely the kernel trying to de-reference a
NULL pointer.  Why this is happening is the question.  Since
you can't invoke the debugger when this happens you might want
to find out where in the kernel this message is coming from
and put a direct call to the debugger at that point.  This
should help to find out what is happening.

On Fri, Oct 27, 2000 at 09:26:28AM -0700, Broadfoot, KenX wrote:
> 
> Just wondering if you all see this error often:
> 
> Unable to handle kernel paging request at virtual address 0000000000000008
> 
> I am using 2.4.0-test9 patched + kdb
> 
> When this happens I can't even get into the debugger.
> 
> This is on a Quad Lion with 2 gigs of Ram
> 
> I see this mostly when running fairly heavy network traffic.
> 
> 
> If anyone is familiar with this and has found a way to minimize it, or can
> explain what it is to me I would appreciate it.
> 
> --ken broadfoot
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

