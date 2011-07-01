From: "H. Peter Anvin" <hpa@zytor.com>
Date: Fri, 01 Jul 2011 16:00:44 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <4E0DEF2C.3040504@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110701144129.GA10052@infradead.org>
	<20110701144641.GA23272@elte.hu>
	<201107011654.06651.ptesarik@suse.cz>
	<20110701153634.GA27407@elte.hu>
In-Reply-To: <20110701153634.GA27407@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 07/01/2011 08:36 AM, Ingo Molnar wrote:
> 
> So we could kill multiple birds with the same stone here:
> 
>  - remove various ugly uses of /dev/mem (including the rootkit usage),
>    with or without strict-devmem
> 
>  - extending it to above-4G for inspection purposes
> 
>  - allowing to kill /dev/mem access runtime similar to the 
>    disable_modules lock-down killswitch, for the so inclined.
> 
> Would you be interested in modifying your patch-set in such a 
> fashion?
> 

There is another use that I have looked at, as well: for testing
purposes, it would be extremely good to be able to dirty and/or flush an
arbitrary physical cache line for testing purposes.

This is very very similar to /dev/mem usage -- access to an arbitrary
chunk of memory -- and a fully enabled /dev/mem can of course support
this use (just mmap the page with the relevant cache line).  However, it
could also be a separate device which could have looser permissions than
/dev/mem; or a set of ioctls on /dev/mem with a separate kill switch,
because no data would ever be have modified or returned to user space.

Either way, though, we found that it would share a lot of code with the
/dev/mem implementation, and as such fixing up the underlying machinery
is the sanest way to upstream this.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

