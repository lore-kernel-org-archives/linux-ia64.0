From: Bill Nottingham <notting@redhat.com>
Date: Mon, 26 Feb 2001 16:17:26 +0000
Subject: [Linux-ia64] Re: 2.4.1 + 010131 patch: sys_nanosleep sleeps... infinitely!
Message-Id: <marc-linux-ia64-105590693005205@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner (steiner@sgi.com) said: 
> We have also been seeing hangs running with the latest BIOS. The problem
> was isolated to a tiny window in arch/ia64/kernel/time.c where
> itm could get loaded with a value that is in the past.

I've certainly seen references to time going in the past recently;
the error messages are usually from ping.

Bill

