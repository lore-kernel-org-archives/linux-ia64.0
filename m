From: Randolph Chung <tausq@debian.org>
Date: Mon, 25 Feb 2002 21:49:51 +0000
Subject: Re: [Linux-ia64] gcc profiling broken on Linux/ia64?
Message-Id: <marc-linux-ia64-105590701905190@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905185@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905185@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Works great, thanks Gary!

Ben, FYI - i'll file a bug against glibc for this.

randolph


In reference to a message from Gary Hade, dated Feb 25:
> Randolph,
> I believe this problem is due to a bug in /usr/lib/gcrt1.o 
> that was fixed by recent glibc changes to csu/gmon-start.c
> (revs 1.13 and 1.14).
> 
> Hope this helps.
> 
> Gary
> 

-- 
Debian Developer <tausq@debian.org>
http://www.TauSq.org/

