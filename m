From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 02 Apr 2003 05:18:52 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] sal calls w/o taking sal_lock
Message-Id: <marc-linux-ia64-105590723705381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 1 Apr 2003 12:28:26 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Tue, 1 Apr 2003 10:06:44 -0800, Jesse Barnes <jbarnes@sgi.com> said:
>
>  Jesse> This patch adds SAL_CALL_NOLOCK so that platforms may call the SAL
>  Jesse> without taking a lock, if appropriate.  The ia64_sal_mc_rendez() has
>  Jesse> been changed to use it, since it won't return until all CPUs have been
>  Jesse> rendevoused by the SAL, if I understand correctly.  It's also used by
>  Jesse> various SN specific SAL routines that access the system controllers
>  Jesse> and might be useful to other plaforms.
>
>http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1113?nav=index.html

I do not understand why you renamed the variables.  The SAL code is
enclosed in do { } while();  All variables within {} are local, they do
not need unique names.


