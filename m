From: Bill Nottingham <notting@redhat.com>
Date: Wed, 21 Feb 2001 18:12:41 +0000
Subject: [Linux-ia64] Re: Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005178@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
> Please be more specific when reporting bugs.  At the least, include
> (a) what type of machine and (b) what kernel patch you were running at
> the time.  Ideally, also describe what you where doing at the time and
> try to get a backtrace with kdb, if possible.

2P BigSur, using UP 010131 kernel, on top of 2.4.1-ac16 (certainly, this
could cause problems).

As to what I was doing, in one case, nothing at all, in another, untarring
a tarball. The video shuts off and the machine is completely dead, which
makes diagnosing what happened difficult (hm, need to find serial cable.)

Since it has happened when I wasn't watching the machine intently,
it's entirely possible it's related to when it turns off the monitor
via DPMS, but that would just be weird.

Bill

