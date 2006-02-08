From: mita@miraclelinux.com (Akinobu Mita)
Date: Wed, 08 Feb 2006 10:41:21 +0000
Subject: Re: [patch 15/44] generic ext2_{set,clear,test,find_first_zero,find_next_zero}_bit()
Message-Id: <20060208104121.GB27490@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090224.536581000@localhost.localdomain> <20060201090326.139510000@localhost.localdomain> <Pine.LNX.4.61.0602011214270.12293@scrub.home>
In-Reply-To: <Pine.LNX.4.61.0602011214270.12293@scrub.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roman Zippel <zippel@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

On Wed, Feb 01, 2006 at 12:27:38PM +0100, Roman Zippel wrote:

> For the inline version I would prefer this version:
> 
> {
> 	const unsigned char *tmp = (const unsigned char *)addr;
> 	return (tmp[nr >> 3] & (unsigned char)(1 << (nr & 7))) != 0;
> }
> 
> Although this would be a good alternative as well:
> 
> {
> 	return (addr[nr >> 5] & (1 << ((nr ^ 24) & 31))) != 0;
> }

Thanks, maybe I could use BITOP_LE_SWIZZLE similar to other *_le_bit().

#define BITOP_LE_SWIZZLE       ((BITS_PER_LONG-1) & ~0x7)
 :
#define generic_test_le_bit(nr, addr) test_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
 :
#endif /* __BIG_ENDIAN */

