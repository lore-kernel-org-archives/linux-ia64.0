From: Jim Wilson <wilson@redhat.com>
Date: Mon, 16 Dec 2002 23:10:21 +0000
Subject: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805581@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I know, but AFAICT it is the latest that is available on the RH site
>for ia64.  If there is a more recent binutils ia64.rpm, point me at it
>and I will try it.

Yes, this is the latest one that we give away free of charge to non-customers.
I think we stopped maintaining these tools a while ago when we started
recommending RH AS 2.[01] instead of RHL 7.[012] for IA-64 customers.

If you want to try something newer, the FSF binutils sources are easily
accessible at
        http://sources.redhat.com/binutils

>See my follow up mail about memset.S, that is pure assembler.

Right, I didn't look closely enough at the file name.  There is unfortunately
no testcase though.  I'll have to grab a copy of the kernel sources in order
to get a testcase.

>[454 lines omitted for brevity]

And this isn't usable as a testcase either.

Jim

