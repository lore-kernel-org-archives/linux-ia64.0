From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 19 Apr 2001 19:23:42 +0000
Subject: Re: [Linux-ia64] 2.4.3 + 010405 hanging
Message-Id: <marc-linux-ia64-105590693005438@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005437@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005437@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Gustavo" = Gustavo Niemeyer <niemeyer@conectiva.com> writes:

Gustavo> Hello!  When I try to do a complex task like kernel compiling
Gustavo> and I'm running kernel 2.4.3 with ia64 patch 010405, the
Gustavo> system is hanging frequently.

Gustavo> Any known issues about this?

There is a known problem with the rw semaphores that can cause
something like this. David included a basic fix in an ldt patch he
posted a couple of days ago.

I think this snippet is the relevant part.

Jes

diff -urN lia64/arch/ia64/kernel/semaphore.c lia64-kdb/arch/ia64/kernel/semaphore.c
--- lia64/arch/ia64/kernel/semaphore.c	Wed Dec  6 18:36:35 2000
+++ lia64-kdb/arch/ia64/kernel/semaphore.c	Fri Apr 13 20:48:40 2001
@@ -321,13 +321,11 @@
 
 	if (count = 0) {
 		/* wake a writer */
-		if (xchg(&sem->write_bias_granted, 1))
-			BUG();
+		xchg(&sem->write_bias_granted, 1);
 		wq = &sem->write_bias_wait;
 	} else {
 		/* wake reader(s) */
-		if (xchg(&sem->read_bias_granted, 1))
-			BUG();
+		xchg(&sem->read_bias_granted, 1);
 		wq = &sem->wait;
 	}
 	wake_up(wq);	/* wake up everyone on the wait queue */

