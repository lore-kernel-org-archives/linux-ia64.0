From: Don Dugger <n0ano@n0ano.com>
Date: Fri, 15 Nov 2002 03:50:36 +0000
Subject: Re: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Two points:

1)  I didn't say data conversion was easy just that the one time effort
of converting would be easier in the long run than the on-going effort
of creating and maintaining, for ever, big endian user libraries.

2)  I thought PA-RISC was a 32-bit processor which means porting to
IA64, assuming you're porting to 64-bit addressing (and if not why are
you porting to IA64 in the first place), will entail data incompatibilities
independent of endian-ness so you still have to do the data conversion.

It comes down to engineering trade offs and I still say that the one time
port will be easier in the long run.

On Thu, Nov 14, 2002 at 07:41:28PM -0800, Grant Grundler wrote:
> Don Dugger wrote:
> > Data compatibility is the only real gotcha I can think of and that's just
> > a translation issue.  Potentially creating the translation utilities will
> > be a problem but I predict it's a smaller problem than coming up with a
> > big endian IA64 Linux.
> 
> Have you ever tried to import wrong-endian data?
> 
> I thought people gave up trying to do that on 16-bit machines.
> I've been in more endian flip-flops than I care to remember.
> (Olivetti flip-flopped about every 2 years in the early 90s, talk
> about customer nightmares...)
> 
> Data conversion has to be re-adressed by *every* application
> because of padding. I think the work mostly cannot be amortized over
> lots of customers.
> 
> I agree with david. User space libs need to be migrated from the
> desired environment. See how far a per-process approach gets first.
> 
> grant
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com

