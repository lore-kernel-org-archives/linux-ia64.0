From: Francis Galiegue <fg@mandrakesoft.com>
Date: Wed, 25 Oct 2000 14:41:46 +0000
Subject: Re: [Linux-ia64] CPU stepping in /proc/cpuinfo?
Message-Id: <marc-linux-ia64-105590678205626@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205623@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205623@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 25 Oct 2000, Jes Sorensen wrote:

> 
> Francis> Right now, /proc/cpuinfo doesn't seem to print $subject,
> Francis> unless the stepping is available from the CPU serial
> Francis> number...
> 
> Francis> Are there patches floating around?
> 
> No - info is not available in any simple way.
> 

Update: someone told me that revision in /proc/cpuinfo was what I was looking
for. 0 means Ax stepping, 1 or more means Bx. Is this the case?

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


