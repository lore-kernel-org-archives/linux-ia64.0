From: Bill Nottingham <notting@redhat.com>
Date: Wed, 27 Jun 2001 18:20:44 +0000
Subject: [Linux-ia64] Re: pthread_mutex_lock sometimes fails on Linux 2.4.5
Message-Id: <marc-linux-ia64-105590693005788@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robboy, David G (david.g.robboy@intel.com) said: 
> On a 4P Lion with Red Hat 7.0.98 installed and a 2.4.5 kernel, a 4P fft
> application sometimes hangs in a barrier.  All 4 threads get into the
> barrier and none get out because a count gets up to 3 and they are waiting
> for it to get to 4.

Stock 2.4.5 or something else?

Bill

