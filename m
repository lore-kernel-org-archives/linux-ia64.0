From: chas williams <chas@cmf.nrl.navy.mil>
Date: Sat, 17 Aug 2002 23:50:11 +0000
Subject: Re: [Linux-ia64] patching the syscall table via a module
Message-Id: <marc-linux-ia64-105590701905952@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905938@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905938@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In message <15709.34404.525197.190900@napali.hpl.hp.com>,David Mosberger writes:
>reasons).  While a bit rude, perhaps the Red Hat approach will force
>those who care to find a better solution. ;-)

i believe the developers of afs are aware of this situation.  i dont
know if the necessary api has materialized yet though.  for the short
term, sys_call_table will need to be writable.

