From: Davide Libenzi <davidel@xmailserver.org>
Date: Fri, 23 May 2003 18:04:45 +0000
Subject: RE: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723706005@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 23 May 2003, Boehm, Hans wrote:

> Sorry about the typo and misnaming for the test program.  I attached the correct version that prints the right labels.
>
> The results I posted did not use NPTL.  (Presumably OpenMP wasn't targeted at NPTL either.)  I don't think that NPTL has any bearing on the underlying issues that I mentioned, though path lengths are probably a bit shorter.  It should also handle contention substantially better, but that wasn't tested.
>
> I did rerun the test case on a 900 MHz Itanium 2 machine with a more recent Debian installation with NPTL.  I get 200msecs (20nsecs/iter) with the custom lock, and 768 for pthreads.  (With static linking that decreases to 658 for pthreads.)  Pthreads (and/or some of the other infrastructure) is clearly getting better, but I don't think the difference will disappear.

To make things more fair you should test against pthread spinlocks. Also,
for tight loops like that, even an extra call deep level (that pthread is
likely to do) is going to matter.



- Davide


