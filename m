From: Bill Nottingham <notting@redhat.com>
Date: Fri, 14 Jun 2002 18:25:50 +0000
Subject: [Linux-ia64] Re: Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xavier Bru (Xavier.Bru@bull.net) said: 
> Is there a clean way to do that for an unexperimented gcc user, in
> particular, can we have a gcc3.1 like installation that allows keeping 
> the gcc2.96 ?

You should be able to rebuild:

 ftp://people.redhat.com/jakub/gcc3/3.1-1/gcc3-3.1-1.src.rpm
 
and get something that installs alongside the 2.96 system compiler.

Bill

