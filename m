From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 03 Sep 2020 17:53:07 +0000
Subject: Re: [PATCH 1/2] dma-mapping: introduce dma_get_seg_boundary_nr_pages()
Message-Id: <7e1c3632-0917-0892-c1ca-8048674a3b05@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200901221646.26491-1-nicoleotsuka@gmail.com>
 <20200901221646.26491-2-nicoleotsuka@gmail.com>
 <CAHp75VcVJBSnPQ6NfdF8FdEDfM+oQ=Sr+cH5VGX4SrAqrgpf-g@mail.gmail.com>
 <20200903161252.GA24841@lst.de>
In-Reply-To: <20200903161252.GA24841@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christoph Hellwig <hch@lst.de>, Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: linux-ia64@vger.kernel.org, James Bottomley <James.Bottomley@hansenpartnership.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, schnelle@linux.ibm.com, hca@linux.ibm.com, Nicolin Chen <nicoleotsuka@gmail.com>, ink@jurassic.park.msu.ru, Thomas Gleixner <tglx@linutronix.de>, gerald.schaefer@linux.ibm.com, rth@twiddle.net, Tony Luck <tony.luck@intel.com>, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, Borislav Petkov <bp@alien8.de>, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>



Le 03/09/2020 à 18:12, Christoph Hellwig a écrit :
> On Thu, Sep 03, 2020 at 01:57:39PM +0300, Andy Shevchenko wrote:
>>> +{
>>> +       if (!dev)
>>> +               return (U32_MAX >> page_shift) + 1;
>>> +       return (dma_get_seg_boundary(dev) >> page_shift) + 1;
>>
>> Can it be better to do something like
>>    unsigned long boundary = dev ? dma_get_seg_boundary(dev) : U32_MAX;
>>
>>    return (boundary >> page_shift) + 1;
>>
>> ?
> 
> I don't really see what that would buy us.
> 

I guess it would avoid the duplication of    >> page_shift) + 1

Christophe
