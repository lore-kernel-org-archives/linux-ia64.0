From: David Howells <dhowells@redhat.com>
Date: Mon, 06 Feb 2006 10:26:00 +0000
Subject: Re: [patch 11/44] generic find_{next,first}{,_zero}_bit()
Message-Id: <12367.1139221560@warthog.cambridge.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090324.373982000@localhost.localdomain>  <20060201090224.536581000@localhost.localdomain> 
In-Reply-To: <20060201090324.373982000@localhost.localdomain> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Chris Zankel <chris@zankel.net>

Akinobu Mita <mita@miraclelinux.com> wrote:

> This patch introduces the C-language equivalents of the functions below:
> 
> unsigned logn find_next_bit(const unsigned long *addr, unsigned long size,
>                             unsigned long offset);
> unsigned long find_next_zero_bit(const unsigned long *addr, unsigned long size,
>                                  unsigned long offset);
> unsigned long find_first_zero_bit(const unsigned long *addr,
>                                   unsigned long size);
> unsigned long find_first_bit(const unsigned long *addr, unsigned long size);

These big functions should perhaps be out of line.

David
