From: Michal Simek <michal.simek@xilinx.com>
Date: Thu, 24 Oct 2019 10:14:31 +0000
Subject: Re: PCI/MSI: Remove the PCI_MSI_IRQ_DOMAIN architecture whitelist
Message-Id: <9ec42e0d-d999-d59c-628a-b7678f132f73@xilinx.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <mhng-d42f23ae-e51f-49cd-9533-a4c793cd70fe@palmer-si-x1e>
In-Reply-To: <mhng-d42f23ae-e51f-49cd-9533-a4c793cd70fe@palmer-si-x1e>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Palmer Dabbelt <palmer@sifive.com>, michal.simek@xilinx.com
Cc: Christoph Hellwig <hch@infradead.org>, helgaas@kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, heiko.carstens@de.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, bhelgaas@google.com, will@kernel.org, Greg KH <gregkh@linuxfoundation.org>, kstewart@linuxfoundation.org, pbonzini@redhat.com, firoz.khan@linaro.org, yamada.masahiro@socionext.com, longman@redhat.com, mingo@kernel.org, peterz@infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-pci@vger.kernel.org

On 22. 10. 19 17:10, Palmer Dabbelt wrote:
> On Thu, 17 Oct 2019 23:20:09 PDT (-0700), michal.simek@xilinx.com wrote:
>> Hi,
>>
>> On 17. 10. 19 20:19, Palmer Dabbelt wrote:
>>> This came up in the context of the microblaze port, where a patch was
>>> recently posted to extend the whitelist.
>>
>> I hoped you were aware about this discussion we have with Christoph.
>> https://lkml.org/lkml/2019/10/8/682
>>
>> It means 1/3 and 2/3 should be replaced by mandatory-y and I expect
>> msi.h can be removed from architecture Kbuild too.
>=20
> I'd missed it, but that seems like a better way to do it.=C2=A0 I'm going=
 to
> assume you guys are going to handle this, so feel free to drop my patch
> set.

Ok. I have sent it with ccing you.

Thanks,
Michal
