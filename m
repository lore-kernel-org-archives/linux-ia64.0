From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Mon, 08 Dec 2003 23:41:41 +0000
Subject: RE: memory fence.
Message-Id: <marc-linux-ia64-107092735901027@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092124126396@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092124126396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You might want to look at the atomic operations package that we distribute
along with qprof (http://www.hpl.hp.com/research/linux/qprof/).  The
most recent released package is at

http://www.hpl.hp.com/research/linux/qprof/download/ao-0.4.tar.gz

Its goal is to implement memory barriers and atomic operations with a portable interface,
while allowing you to describe exactly the functionality you need, so that
you can avoid unnecessary run-time costs when porting between architectures.  It
currently supports X86, IA64, and PA-RISC Linux reasonably well, and has
the beginnings of ports to various other architectures.

Additional ports are always welcome.  And the package is designed to make
the machine-dependent piece as small as possible, typically on the order of
100 lines.

[Caution: The current version installs as "ao", which is now known to
conflict with an audio library.  The name will be changed to atomic_ops in
the next release, which is expected to happen RSN.  In the meantime please be
careful about installing it in /usr.]

Hans


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Umut Aymakoglu
> Sent: Monday, December 08, 2003 2:02 PM
> To: linux-ia64@vger.kernel.org
> Subject: memory fence.
> 
> 
> 
> 
> 
> 
> Hi -
>  Does anybody know the equivalance of  _Asm_mf() (HP ia64) on 
> Linux ia64?
> 
> thanks,
> Umut
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
