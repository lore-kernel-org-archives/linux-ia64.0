From: Colin Ngam <cngam@sgi.com>
Date: Wed, 09 Mar 2005 18:12:37 +0000
Subject: Re: PCI Express
Message-Id: <422F3C95.3070007@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nguyen, Tom L wrote:

>On Tue, Mar 08, 2005 at 05:29:13PM -0800, Jesse Barnes wrote:
>...
>  
>
>>An MSI should behave like a processor sending an IPI to itself since
>>    
>>
>its 
>  
>
>>address can be targeted at the processor's interrupt block and set to 
>>generate a local interrupt.  Is that right, Tom & Grant?
>>    
>>
>
>MSI address is programmed at 0xfeex_xxxx (based on PCI Specs) to
>
Hi Tom,

The MSI address portion allows 64bits for the address.  It should be an 
address whereby a specific Platform has configured with sufficient 
information to generate an Interrupt to the targeted "cpu" with the 
payload - IRQ.

I am very much interested in your assertion that the MSI address is 
defined by PCI Spec to be 0xfeex_xxxx.  Can you kindly point me to the 
relevent section?  Perhaps if you have an online copy, can you cut and 
paste the relevent section?

Thanks.

colin

>generate a memory write to FSB. This address can be configured to target
>a platform interrupt controller (like IOAPIC for example), which in turn
>generates a memory write to a FSB, or be configured to send a memory
>write directly to FSB. Existing MSI support implements a direct
>memory-write mechanism (generic solution without platform dependency and
>limitation to MSI-X support as an example). With existing direct
>memory-write mechanism, a device's MSI address is configured with
>current running CPU as a target. MSI support also implements MSI SMP
>affinity, which supports IRQ rebalance and allows user to select which
>CPU target through /proc/irq/...
>
>I hope it helps.
>
>Thanks,
>Long 
>  
>


