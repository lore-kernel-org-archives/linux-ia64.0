From: Bill Nottingham <notting@redhat.com>
Date: Tue, 05 Dec 2000 22:23:07 +0000
Subject: [Linux-ia64] Re: Fault 26?
Message-Id: <marc-linux-ia64-105590678205793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill Nottingham (notting@redhat.com) said: 
> >   Bill> What is fault type 26?  I'm getting a few of these recently.
> > 
> > It's the "NaT consumption fault".  Either buggy code is trying to eat
> > a NaT value or something else goes wrong and a NaT value is created
> > when it shouldn't be.
> 
> Hm. We're getting it (in cpp) when building the kernel.

Also occasionally in ld, rpm, find, etc.

Bill

