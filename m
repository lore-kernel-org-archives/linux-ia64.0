From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Feb 2006 15:11:34 +0000
Subject: RE: [PATCH 1/12] generic *_bit()
Message-Id: <200602011511.k11FBgg00314@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060126032918.GB9984@miraclelinux.com>
References: <20060126032918.GB9984@miraclelinux.com>
In-Reply-To: <20060126032918.GB9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Akinobu Mita' <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Akinobu Mita wrote on Wednesday, January 25, 2006 7:29 PM
> This patch introduces the C-language equivalents of the functions below:
> 
> - atomic operation:
> void set_bit(int nr, volatile unsigned long *addr);
> void clear_bit(int nr, volatile unsigned long *addr);
> void change_bit(int nr, volatile unsigned long *addr);
> int test_and_set_bit(int nr, volatile unsigned long *addr);
> int test_and_clear_bit(int nr, volatile unsigned long *addr);
> int test_and_change_bit(int nr, volatile unsigned long *addr);

I wonder why you did not make these functions take volatile
unsigned int * address argument?

- Ken

