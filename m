From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 25 Jan 2001 15:34:48 +0000
Subject: Re: [Linux-ia64] That getpagesize() problem again!
Message-Id: <marc-linux-ia64-105590693005100@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 25 Jan 2001, Jes Sorensen wrote:

> 
> |> What should I do?
> 
> Andreas> You need to run kernel 2.4.0-test9 with the 001030 patch or
> Andreas> later.  Earlier versions didn't pass AT_PAGESZ in all cases.
> 
> Actually the problem is that Francis' rpm binaries have been compiled
> and linked statically against an old version of glibc that didn't get
> the pagesize from AT_PAGESZ.
> 
> Francis you need to get a proper set of RPM binaries for your machines
> linked against the new library.
> 

Uhwell, I compiled against glibc 2.2.1...

Anyway, I'm going to reboot under 2.4.0 + patch and see if this cures the
problem... More info later...

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


