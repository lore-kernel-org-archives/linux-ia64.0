From: Randolph Chung <randolph@tausq.org>
Date: Sat, 19 Apr 2003 00:55:53 +0000
Subject: Re: [Linux-ia64] 32 bit syscall unification in 2.5
Message-Id: <marc-linux-ia64-105590723705573@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705570@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705570@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In reference to a message from David Mosberger, dated Apr 18:
> >>>>> On Fri, 18 Apr 2003 17:41:17 -0700, Randolph Chung <randolph@tausq.org> said:
> 
>   Randolph> I sent David a similar patch already. I'm not submitting
>   Randolph> them directly to Linus per David's request.
> 
> So which patch should I use?  I don't have yours handy anymore (not
> without some digging, at least).

Arun's looks good. I'm not sure what the bit in kernel/sys.c is about
though, but I trust he has his reasons for adding it :-)

On the subject of syscall unification patches, there's one on lkml
(compat_sys_nfsservctl) and another large one that i'm reviewing this
weekend for compat_sys_ioctl. I'm not sure I'll be able to test those on
ia64... any volunteers who would like to test these out before i send
them out to Linus and David? 

thanks
randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

