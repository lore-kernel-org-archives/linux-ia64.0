From: Michael Tokarev <mjt@tls.msk.ru>
Date: Thu, 26 Jan 2006 08:21:57 +0000
Subject: Re: [PATCH 3/12] generic ffz()
Message-Id: <43D886A5.8010309@tls.msk.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060125205907.GF9995@esmail.cup.hp.com> <20060126032713.GA9984@miraclelinux.com> <20060126033156.GB11138@miraclelinux.com>
In-Reply-To: <20060126033156.GB11138@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Akinobu Mita wrote:
> This patch introduces the C-language equivalent of the function:
> unsigned long ffz(unsigned long word);
[]
> +#define ffz(x)	__ffs(~x)

please consider using
   #define ffz(x)	__ffs(~(x))

instead -- note the extra ()-pair

/mjt
