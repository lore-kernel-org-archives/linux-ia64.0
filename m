From: Hugo Kohmann <hugo@dolphinics.no>
Date: Wed, 12 Jan 2005 19:31:30 +0000
Subject: RE: pgprot_writecombine & shub 1.x
Message-Id: <Pine.LNX.4.61.0501122017280.8735@boss.dolphinics.no>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

Is there any new plans to implement support for writecombine in kernel 
space ?

We have implemented a new socket transport family, AF_SCI, that provides
UDP/TCP compliant transport over SCI that needs writecombine to archieve
max througpht and low latency for small messages. Large messages can be 
send using DMA, but small messages highly benefit from memory 
mapped transmission....

Best regards

Hugo Kohmann
Dolphin Interconnect Solutions


On Wed, 12 Jan 2005, Jim Hull wrote:

>Date: Wed, 12 Jan 2005 10:51:49 -0800
>From: Jim Hull <jim.hull@hp.com>
>To: 'Jesse Barnes' <jbarnes@sgi.com>,
>    "Mosberger, David" <david.mosberger@hp.com>
>Cc: linux-ia64@vger.kernel.org, 'Tony Luck' <tony.luck@intel.com>
>Subject: RE: pgprot_writecombine & shub 1.x
>
> Jesse Barnes wrote:
>
>> But what about places that unconditionally set the WC bit
>> regardless of what the EFI memory map says?
>
> To be blunt - those places are broken, at least from the perspective of the IPF
> (ia64 if you prefer) architecture.  IPF declares that it is the platform which
> gets to decide the supported attributes for each address range, and provides the
> EFI memory map to inform the OS of this support.
>
>> pci_mmap_page_range does this for
>> example if the write_combine flag is set on the vma.
>> I'm looking for a way to abstract out
>> uses like that, so that shub 1.x systems don't set the bit.
>
> I'm not really qualified to design the right linux interfaces, but to be IPF
> compliant, you need to change all such places to first consult the EFI memory
> map.  Whether you do this once at boot time, on every call, whether to fail an
> unsupported request or remap the attribute to something the platform can support
> (e.g., mapping WC to UC), is all up to you.
>
> -- Jim
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


============================================Hugo Kohmann                           |
Dolphin Interconnect Solutions AS      | E-mail:
P.O. Box 150 Oppsal                    | hugo@dolphinics.com
N-0619 Oslo, Norway                    | Web:
Tel:+47 23 16 71 83                    | http://www.dolphinics.com
Fax:+47 23 16 71 80                    | 
Visiting Address: Olaf Helsets vei 6   |
