From: "Maciej W. Rozycki" <macro@imgtec.com>
Date: Fri, 29 Jan 2016 13:38:59 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <alpine.DEB.2.00.1601291333130.5958@tp.orcam.me.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160113104516.GE25458@arm.com> <5696CF08.8080700@imgtec.com> <20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com> <20160114203430.GC3818@linux.vnet.ibm.com> <56980C91.1010403@imgtec.com> <20160114212913.GF3818@linux.vnet.ibm.com>
 <569814F2.50801@imgtec.com> <20160114225510.GJ3818@linux.vnet.ibm.com> <56983054.4070807@imgtec.com> <20160115004753.GN3818@linux.vnet.ibm.com> <56984642.3090106@imgtec.com> <alpine.DEB.2.00.1601271116520.5958@tp.orcam.me.uk> <56A9656D.3080707@imgtec.com>
In-Reply-To: <56A9656D.3080707@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: paulmck@linux.vnet.ibm.com, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge

On Thu, 28 Jan 2016, Leonid Yegoshin wrote:

> In http://patchwork.linux-mips.org/patch/10505/ the very last mesg exchange
> is:
[...]
> ... and that stops forever...

 Thanks for the reminder -- last June was very hectic, I travelled a lot 
and I lost the discussion from my radar.  Apologies for that.  I replied 
in that thread now with my results.  I hope this helps.

  Maciej
