From: Erich Focht <efocht@ess.nec.de>
Date: Thu, 11 Jul 2002 09:25:26 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905763@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905752@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905752@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ingo,

the last fix survived one night of testing with included udelay(100), so
I would consider it stable. Thanks again!

The performance with the new "complex" macros is as expected worse than
with the simple ones, we see 10% in some cases, which is hurting a lot.
Would you please consider moving the location of the switch_lock from
the end of the task_struct to the hot area near the scheduler related
variables? The effect may vary depending on the cache line size but
having it behind *array or sleep_timestamp would probably save us a cache
miss here.

Regards,
Erich


