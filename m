From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 11 Dec 2002 23:26:08 +0000
Subject: Re: [Linux-ia64] fpswa logging redux
Message-Id: <marc-linux-ia64-105590709805549@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805545@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805545@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 12, 2002 at 10:17:20AM +1100, Keith Owens wrote:
> On Wed, 11 Dec 2002 15:12:18 -0800, 
> Jesse Barnes <jbarnes@sgi.com> wrote:
> >On Thu, Dec 12, 2002 at 10:07:57AM +1100, Keith Owens wrote:
> >> I have a couple of Perl scripts for decoding isr and psr.  They read
> >> hex values (with or without the leading 0x) from stdin and pretty print
> >> the result.
> >
> >It's the isr code field I'm particularly interested in.  For fp faults
> >and traps, I'd like to decode what type of fault/trap occured and add it
> >to the printk, e.g.
> >Dec 11 17:11:05 morale kernel: a.out(1901): floating-point assist trap : ip@00000000000752
> >Dec 11 17:11:05 morale kernel: a.out(1901): floating-point assist fault : software assist ip@00000000000c01
> 
> The general approach is that the kernel prints raw values and user
> space decodes them, unless there is some overriding reason to do it in
> kernel.  IOW, print the isr in the kernel but decode it using the
> scripts or equivalent.

But if we do that the si_code field of siginfo won't have useful
information.  My thought was that if we decode isr in enough detail to
fill in si_code correctly, we may as well make the printks more useful
as well.  I think all this stuff would be in arch/ia64/kernel/traps.c,
with the possible exception of another SIGFPE code for software assist
faults (and maybe denormal/unnormal).

Thanks,
Jesse

