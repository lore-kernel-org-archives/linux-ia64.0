From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 15 Nov 2002 03:41:28 +0000
Subject: Re: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don Dugger wrote:
> Data compatibility is the only real gotcha I can think of and that's just
> a translation issue.  Potentially creating the translation utilities will
> be a problem but I predict it's a smaller problem than coming up with a
> big endian IA64 Linux.

Have you ever tried to import wrong-endian data?

I thought people gave up trying to do that on 16-bit machines.
I've been in more endian flip-flops than I care to remember.
(Olivetti flip-flopped about every 2 years in the early 90s, talk
about customer nightmares...)

Data conversion has to be re-adressed by *every* application
because of padding. I think the work mostly cannot be amortized over
lots of customers.

I agree with david. User space libs need to be migrated from the
desired environment. See how far a per-process approach gets first.

grant

