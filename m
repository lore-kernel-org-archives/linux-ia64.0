From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 11 Dec 2002 23:12:18 +0000
Subject: Re: [Linux-ia64] fpswa logging redux
Message-Id: <marc-linux-ia64-105590709805547@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805545@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805545@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 12, 2002 at 10:07:57AM +1100, Keith Owens wrote:
> I have a couple of Perl scripts for decoding isr and psr.  They read
> hex values (with or without the leading 0x) from stdin and pretty print
> the result.

It's the isr code field I'm particularly interested in.  For fp faults
and traps, I'd like to decode what type of fault/trap occured and add it
to the printk, e.g.
Dec 11 17:11:05 morale kernel: a.out(1901): floating-point assist trap : ip@00000000000752
Dec 11 17:11:05 morale kernel: a.out(1901): floating-point assist fault : software assist ip@00000000000c01

Jesse

