From: Nobuhiko Yoshida <n-yoshida@pst.fujitsu.com>
Date: Tue, 16 Mar 2004 03:15:08 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <JM20040316121508.13008671@pst.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316015401.GF9931@wotan.suse.de>
In-Reply-To: <20040316015401.GF9931@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org
Cc: raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, Hirokazu Takahashi <taka@valinux.co.jp>

Hello,

> > +/*      update_mmu_cache(vma, address, *pte); */
> 
> I have not studied low level IA64 VM in detail, but don't you need
> some kind of TLB flush here?

Oh! Yes.
Perhaps, TLB flush is needed here.

Thank you,
Nobuhiko Yoshida
