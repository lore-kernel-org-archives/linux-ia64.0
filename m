From: Davide Libenzi <davidel@xmailserver.org>
Date: Sat, 24 May 2003 14:43:12 +0000
Subject: RE: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723706029@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 23 May 2003, Davide Libenzi wrote:

> You need a write memory barrier even on the unlock. Consider this :
>
> 	spinlock = 1;
> 	...
> 	protected_resource = NEWVAL;
> 	spinlock = 0;
>
> ( where spinlock = 0/1 strip down, but do not lose the concept, the lock
> operation ). If a CPU reorder those writes, another CPU might see the lock
> drop before the protected resource assignment. And this is usually bad
> for obvious reasons.

David made me notice about a brain misfire here. You need protection even
for loads crossing the unlock. For the same obvious reasons :) Yes, a
realease barrier will be sufficent for ia64, while you'll need an mfence
on P4.



- Davide


