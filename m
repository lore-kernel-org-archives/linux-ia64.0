From: Randolph Chung <randolph@tausq.org>
Date: Sat, 19 Apr 2003 00:41:17 +0000
Subject: Re: [Linux-ia64] 32 bit syscall unification in 2.5
Message-Id: <marc-linux-ia64-105590723705571@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705570@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705570@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In reference to a message from Arun Sharma, dated Apr 18:
> 
> This patch was commited to Linus' tree a couple of days ago.
> 
> ChangeSet@1.1054.1.17, 2003-04-16 21:45:43-07:00, tausq@debian.org
>   [PATCH] getrlimit,setrlimit,getrusage,wait4 unification
> 
> (Note: the changeset numbers could change over time. To lookup the
> above change at a later date, you may need to use this key:
> tausq@debian.org|ChangeSet|20030417044543|02530 )
> 
> Changes were made to many architectures, but not ia64. The attached
> patch makes a rougly equivalent change to ia64.

I sent David a similar patch already. I'm not submitting them directly
to Linus per David's request.

Don't worry, I'm not leaving ia64 out on purpose ;-)

randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

