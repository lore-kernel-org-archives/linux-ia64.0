From: Colin Ngam <cngam@sgi.com>
Date: Mon, 07 Mar 2005 20:40:42 +0000
Subject: Re: PCI Express
Message-Id: <422CBC4A.7050904@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

Hi Grant,

Thanks for your respond.

>On Fri, Mar 04, 2005 at 05:42:08PM -0600, Colin Ngam wrote:
>  
>
>>Is MSI/MSIX support available for ia64?
>>    
>>
>
>Yes
>
I looked at Documentation/MSI-HOWTO.txt(linux-ia64-release-2.6.11) and 
it mentioned that CONFIG_X86_LOCAL_APIC has to be configured.  I did not 
find this configured on in any sample ia64 config files, but it does 
exist in defconfig for i386.  Is this just an ia32 config option?

>
>  
>
>>Are PCIE devices supported in ia
>>
>>    
>>
>
>I'm having trouble with the word "supported".
>You have a PCI-E Bridge and firmware that can talk to it
>hooked up to an ia64 box?
>
Pretty soon.

Is there any ia64 box with MSI and PCIE actually "activated and running"?

Thanks.

colin

>
>Anyway, linux has some PCI-E support in the generic PCI code.
>
>  
>
>>A pointer to any documentations with regards to PCIE and ia64 will
>>be very much appreciated.
>>    
>>
>
>I don't think anything ia64 or linux specific exists.
>
>grant
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  
>


