From: Colin Ngam <cngam@sgi.com>
Date: Wed, 09 Mar 2005 17:42:39 +0000
Subject: Re: PCI Express
Message-Id: <422F358F.5010307@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

>On Wed, Mar 09, 2005 at 08:35:00AM -0800, Nguyen, Tom L wrote:
>  
>
>>Existing MSI support implements a direct
>>memory-write mechanism (generic solution without platform dependency and
>>limitation to MSI-X support as an example). With existing direct
>>memory-write mechanism, a device's MSI address is configured with
>>current running CPU as a target.
>>    
>>
>
>At some point, PARISC (and Alpha?) will also want to support MSI
>using "direct memory write". But like Altix, does not implement
>0xfeeXXXXX (1) PIB since PARISC arch predates PCI by a decade or so.
>
>We'll have to figure out which platform specific hooks would enable
>parisc/alpha/altix to use existing PCI MSI/MSI-X support.
>
Hi Grant,

Sounds great.

Thanks.

colin

>
>PA-RISC IPI is as straight forward as Jesse described - just write
>to a per CPU address with a data value (vector).
>
>thanks,
>grant
>
>(1) the most recent two or three PA-RISC chipsets do implement 0xfeeXXXXX
>interrupt block. But firmware hands us the CPU "ID/EID" values to use
>when programming the IO SAPIC IRT. See drivers/parisc/iosapic.c
>iosapic_set_irt_data() for more details.
>
>Bottomline is, even if we know it's implemented in HW, we don't know if
>we are using 0xfeeXXXXX or not for IO SAPIC today. platform hooks
>into MSI code would have to sort that out.
>  
>


