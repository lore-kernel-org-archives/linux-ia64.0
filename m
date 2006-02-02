From: "Rune Torgersen" <runet@innovsys.com>
Date: Thu, 02 Feb 2006 15:05:33 +0000
Subject: RE: [patch 10/44] generic fls64()
Message-Id: <DCEAAC0833DD314AB0B58112AD99B93B859547@ismail.innsys.innovsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090323.294297000@localhost.localdomain>
In-Reply-To: <20060201090323.294297000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, Ian Molton <spyro@f2s.com>, David Howells <dhowells@redhat.com>, linuxppc-dev@ozlabs.org, Greg Ungerer <gerg@uclinux.org>, sparclinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Linus Torvalds <torvalds@osdl.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, linuxsh-shmedia-dev@lists.sourceforge.net, linux-m68k@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, dev-etrax@axis.com, ultralinux@vger.kernel.org, Andi Kleen <ak@suse.de>, linuxsh-dev@lists.sourceforge.net, linux390@de.ibm.com, Russell King <rmk@arm.linux.org.uk>, parisc-linux@parisc-linux.org

> From: Akinobu Mita
> Sent: Wednesday, February 01, 2006 03:03
> +static inline int fls64(__u64 x)
> +{
> +	__u32 h = x >> 32;
> +	if (h)
> +		return fls(x) + 32;

Shouldn't this be return fls(h) + 32; ??
                            ^^^
> +	return fls(x);
> +}
> +
> +#endif /* _ASM_GENERIC_BITOPS_FLS64_H_ */
> 
> --
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
> 
> 
