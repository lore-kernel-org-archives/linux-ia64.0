From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 15 Mar 2003 01:27:00 +0000
Subject: Re: [Linux-ia64] How to set/reset gp pointer : info needed
Message-Id: <marc-linux-ia64-105590709806126@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Mar 2003 11:41:57 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 14 Mar 2003 09:56:12 -0800 (PST), Raj Patil <rpatil0296@yahoo.com> said:
>
>  Raj> I will check the source of this tool/module......  But,
>  Raj> curious: You mean, one can not legally add a new syscall or
>  Raj> hook?
>
>I don't want to appear to be giving legal advise, so I'd recommend to
>consult with your legal counsel to get a definite answer (or you can
>ask for opinions on the lkml; preferably _after_ donning an asbestos
>suit).

Even beyond legal - Linus has stated (several times) that he will not
accept code that patches the syscall table.  Linus hates the idea of
dynamic syscalls.


