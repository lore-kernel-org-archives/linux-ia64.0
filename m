From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 18 Mar 2002 23:56:25 +0000
Subject: Re: [Linux-ia64] Re: compiler version for kernel builds
Message-Id: <marc-linux-ia64-105590701905302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> >>>>> On Thu, 14 Mar 2002 15:46:04 -0800, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> David, which compiler version do you use for kernel builds
>   Jesse> these days?
> 
> I usually use 3.0, though I try to remember to test with 2.96 from
> time to time.  I haven't had much luck with 3.1 yet: it builds a
> working kernel for the simulator, but the kernel for the real machine
> dies early on.  Haven't had time yet to investigate.

I have just tested 3.0.5 (20020316) and I can't get a booting
2.5.7pre1 kernel built with that toolchain.

Seems it's not just 3.1+ thats borked ;-(

Jes
c

