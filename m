From: Palmer Dabbelt <palmer@sifive.com>
Date: Tue, 22 Oct 2019 15:10:48 +0000
Subject: Re: PCI/MSI: Remove the PCI_MSI_IRQ_DOMAIN architecture whitelist
Message-Id: <mhng-d42f23ae-e51f-49cd-9533-a4c793cd70fe@palmer-si-x1e>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <995f625b-1f56-6d97-ba99-9a4298e9dd37@xilinx.com>
References: <20191017181937.7004-1-palmer@sifive.com>
In-Reply-To: <20191017181937.7004-1-palmer@sifive.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: michal.simek@xilinx.com
Cc: Christoph Hellwig <hch@infradead.org>, helgaas@kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, heiko.carstens@de.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, bhelgaas@google.com, will@kernel.org, Greg KH <gregkh@linuxfoundation.org>, kstewart@linuxfoundation.org, pbonzini@redhat.com, firoz.khan@linaro.org, yamada.masahiro@socionext.com, longman@redhat.com, mingo@kernel.org, peterz@infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-pci@vger.kernel.org

On Thu, 17 Oct 2019 23:20:09 PDT (-0700), michal.simek@xilinx.com wrote:
> Hi,
>
> On 17. 10. 19 20:19, Palmer Dabbelt wrote:
>> This came up in the context of the microblaze port, where a patch was
>> recently posted to extend the whitelist.
>
> I hoped you were aware about this discussion we have with Christoph.
> https://lkml.org/lkml/2019/10/8/682
>
> It means 1/3 and 2/3 should be replaced by mandatory-y and I expect
> msi.h can be removed from architecture Kbuild too.

I'd missed it, but that seems like a better way to do it.  I'm going to assume 
you guys are going to handle this, so feel free to drop my patch set.

Thanks!
