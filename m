From: "Bryan O'Sullivan" <bos@serpentine.com>
Date: Fri, 27 Jan 2006 05:23:47 +0000
Subject: Re: [PATCH 8/12] generic hweight{32,16,8}()
Message-Id: <1138339428.9435.7.camel@camp4.serpentine.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	 <20060125113206.GD18584@miraclelinux.com>
	 <20060125200250.GA26443@flint.arm.linux.org.uk>
	 <20060125205907.GF9995@esmail.cup.hp.com>
	 <20060126032713.GA9984@miraclelinux.com>
	 <20060126033613.GG11138@miraclelinux.com>
	 <1138301867.12632.71.camel@serpentine.pathscale.com>
	 <20060127044303.GA6594@miraclelinux.com>
In-Reply-To: <20060127044303.GA6594@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Fri, 2006-01-27 at 13:43 +0900, Akinobu Mita wrote:

> I think it's better than adding many HAVE_ARCH_*_BITOPS.
> I will have 14 new headers. So I want to make new directory
> include/asm-generic/bitops/:

While you're thrashing all that stuff, have you thought about adding
generic support for the atomic_*_mask functions?  Only eight of almost
30 arches actually implement them, which makes them worthless for
portable drivers.  The same approach you're using now with other bitops
will work equally well, or be just as broken, depending on the arch in
question :-)

	<b

