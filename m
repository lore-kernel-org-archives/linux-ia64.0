From: Colin Ngam <cngam@sgi.com>
Date: Wed, 09 Mar 2005 21:44:45 +0000
Subject: Re: PCI Express
Message-Id: <422F6E4D.5090808@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nguyen, Tom L wrote:

>On Wednesday, March 09, 2005 10:48 AM Grant Grundler wrote:
>
>  
>
>>>I am very much interested in your assertion that the MSI address is 
>>>defined by PCI Spec to be 0xfeex_xxxx.
>>>      
>>>
>>...
>>    
>>
>>>Can you kindly point me to the relevent section?
>>>      
>>>
>>It's not and it doesn't belong there.
>>
>>IA64 specs defines Processor Interrupt Block and where it lives.
>>See "Intel(r) Itanium(r) Software Developer's Manual"
>>	Volume 2, Part 1, Section 5.8.4
>>	Volume 2, Part 1, Section 11.9.3
>>    
>>
>
>I apologize that it is not in PCI Spec. It is also in Section 8.11 of
>"IA-32 Intel Architecture Software Developer's Manual (volume 3)."
>

Hi,

Thanks Tom.

I believe we are all are in agreement that the MSI Address needs to be 
Platform "Tunable" :-)

Thank you.

colin

>
>Thanks,
>Long
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  
>


