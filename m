From: Eric Piel <Eric.Piel@Bull.Net>
Date: Fri, 11 Apr 2003 14:33:33 +0000
Subject: Re: [Linux-ia64] [BUG] perfmon doesn't send SIGPROF in kernel 2.5.64
Message-Id: <marc-linux-ia64-105590723705466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705454@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705454@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> Yes, I realized that a while back and never got around to fixing it.
> 
> Please try the (mostly untested) attached patch against 2.5.67 but it
> should apply to older versions as well.
Thank you for the patch, testing on a 2.5.64 kernel (I don't have 2.5.67
yet :-) ) with and without preempt.
Hardware : tiger (4x Itanium2)
 
> Let me know how it goes, especially on SMP.
For now I would say it doesn't work :-( I get the same results from
realfeel4 than before.
However it works better (in a point of view) than before because now
pfm_ovfl_block_reset() is called and sends a SIGPROF. But this is done
only at the very end of realfeel4, according to the logs I think it's
when sending the SIGALRM.

Eric

> PS: there is a dedicated mailing-list for perfmon.
Sorry, I hadn't noticed, I'm now cross-posting.

