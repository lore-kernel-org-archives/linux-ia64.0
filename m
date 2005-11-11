From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 11 Nov 2005 00:13:02 +0000
Subject: RE: [Patch 1/1] 4-level page tables v4.
Message-Id: <200511110013.jAB0D2g21969@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Thursday, November 10, 2005 2:39 PM
> I am going to attach the dispersal analysis the modified objdump that
> Jack has produced.

>  5c:    8 S                   cmp.eq p6,p7=5,r17
>  60:    8         [MII]       nop.m 0x0
>  66:    8                     shr.u r18=r22,36;;

Hmm, I think the dispersal analysis software is buggy.  At least for
the above instance.  Immediate form of shr is pseudo-op'ed to extr.
It should count the above bundle with 2 cycles instead of one cycle.

- Ken

