From: n0ano@indstorage.com
Date: Tue, 16 Apr 2002 22:35:37 +0000
Subject: Re: [Linux-ia64] unw_init_frame_info() and activation records
Message-Id: <marc-linux-ia64-105590701905463@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905462@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905462@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All-

Just a friendly note from the mailing list administrator.  I let this
post go through but this is probably something that should have been
put up on an `ftp' server somewhere with a note about it's existence
sent to the list.  I don't want to put hard size limits on anyone but
we all should use common sense and use `ftp' servers where appropriate.

Tnx.

On Tue, Apr 16, 2002 at 02:55:21PM -0700, Piet/Pete Delaney wrote:
> Hi Keith:
> 
> Our linux lcrash code support for stack frames needs improvement, I'm
> looking around for code to pinch and was wondering about the kdb code.
> 
> The kdb code at least seems to support the NEW_UNWIND code by using 
> unw_init_frame_info().  You code mentions that it should be using activation 
> records and I was wondering what that's all about.
> 
> I've been reading Davie Mosberger chapter on Stack Unwinding and I'll check the
> kernel code for perspectives on the code. I suspect that the gdb unwind code
> and the HP-IPF-unwind library (see attached) are likely an overkill and only
> needed for C++.
> 
> Perhaps you could take a few minutes and provide a few pointers on how
> to save time in adding unwind support. 
> 
> -piet
> 
> 
> 



-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

