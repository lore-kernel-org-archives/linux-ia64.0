From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Mon, 26 May 2014 09:52:32 +0000
Subject: Re: [PATCH] PCI: Turn pcibios_penalize_isa_irq() into __weak function
Message-Id: <53830EE0.1070700@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399346992-6584-1-git-send-email-hanjun.guo@linaro.org> <4534160.Diq8cthzci@wuerfel>
In-Reply-To: <4534160.Diq8cthzci@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, linux-pci@vger.kernel.org, x86@kernel.org, Will Deacon <will.deacon@arm.com>, Yijing Wang <wangyijing@huawei.com>, Thomas Gleixner <tglx@linutronix.de>

On 2014-5-6 15:26, Arnd Bergmann wrote:
> On Tuesday 06 May 2014 11:29:52 Hanjun Guo wrote:
>> pcibios_penalize_isa_irq() is only useful for x86 now, and
>> legacy ISA is not used by some architectures, so make
>> pcibios_penalize_isa_irq() as __weak function to simplify
>> the code, this will prevent new platform from introducing
>> dummy stub function for pcibios_penalize_isa_irq() too.
>>
>> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> 

Hi Bjorn,

Any comments on this patch?

Thanks
Hanjun
