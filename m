From: Patrick Gefre <pfg@sgi.com>
Date: Tue, 03 Feb 2004 23:15:44 +0000
Subject: Re: PCI question
Message-Id: <40202BA0.3070507@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:

>On Tue, Feb 03, 2004 at 04:35:26PM -0600, Pat Gefre wrote:
>  
>
>>The usage of pci_dev.sysdata is a bit confusing to me. I had initially
>>thought that this was available for any system specific use,  but then
>>in pcibios_fixup_device_resources() it is specifically cast as a struct
>>pci_controller *:
>>    
>>
>
>It's up to the architecture how it's used.  ia64 has decided that it
>shall be a struct pci_controller *.
>
>  
>
>>In this funtion  the pci_controller elements 'window[]' and 'windows'
>>are also used.  This implies to me that these fields must be maintained
>>in any system specific structure ? i.e.
>>
>>struct my_sysdata_struct {
>>   struct pci_controller dummy;
>>   /* my stuff would go here */
>>   struct my_real_sysdata_stuff;
>>};
>>
>>Yet I don't see where anyone else is doing the above. Am I missing
>>something obvious ??
>>    
>>
>
>Urgh, don't do that.  What do you need to do that can't be added to the
>pci_controller?
>
>  
>
OK- good - thanks. Yes the other option is to add it to the 
pci_controller struct.

-- Pat


