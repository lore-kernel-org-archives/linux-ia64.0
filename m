From: Bill Nottingham <notting@redhat.com>
Date: Wed, 27 Jun 2001 18:44:18 +0000
Subject: [Linux-ia64] Re: Re: pthread_mutex_lock sometimes fails on Linux 2.4.5
Message-Id: <marc-linux-ia64-105590693005790@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robboy, David G (david.g.robboy@intel.com) said: 
> > Stock 2.4.5 or something else?
> 
> Something else.  We have features of our own in the kernel for system
> validation.  I guess I should try it on a stock kernel.

Just checking; the main thing is to make sure you aren't using
an -ac based kernel; pthreads will *not* work on this on ia64 without
some patching.

Bill

