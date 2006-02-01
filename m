From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 01 Feb 2006 18:02:37 +0000
Subject: Re: [PATCH 1/12] generic *_bit()
Message-Id: <20060201180237.GA18464@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060126032918.GB9984@miraclelinux.com> <200602011511.k11FBgg00314@unix-os.sc.intel.com>
In-Reply-To: <200602011511.k11FBgg00314@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Akinobu Mita' <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Feb 01, 2006 at 07:11:34AM -0800, Chen, Kenneth W wrote:
> Akinobu Mita wrote on Wednesday, January 25, 2006 7:29 PM
> > This patch introduces the C-language equivalents of the functions below:
> > 
> > - atomic operation:
> > void set_bit(int nr, volatile unsigned long *addr);
> > void clear_bit(int nr, volatile unsigned long *addr);
> > void change_bit(int nr, volatile unsigned long *addr);
> > int test_and_set_bit(int nr, volatile unsigned long *addr);
> > int test_and_clear_bit(int nr, volatile unsigned long *addr);
> > int test_and_change_bit(int nr, volatile unsigned long *addr);
> 
> I wonder why you did not make these functions take volatile
> unsigned int * address argument?

Because they are defined to operate on arrays of unsigned long
