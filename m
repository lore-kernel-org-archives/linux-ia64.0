From: "A. Devine" <devine@dna.ie>
Date: Sun, 07 Sep 2008 12:25:33 +0000
Subject: Re: Graphics support - ATI vs nVidia
Message-Id: <D2ACCD6DC10244B79038210F3101B59D@kodax64>
List-Id: <linux-ia64.vger.kernel.org>
References: <7C4B5C8349AD4AC082AD250928FB330D@kodax64>
In-Reply-To: <7C4B5C8349AD4AC082AD250928FB330D@kodax64>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

----- Original Message ----- 
From: "A. Devine" <devine@dna.ie>
To: "Luck, Tony" <tony.luck@intel.com>; <linux-ia64@vger.kernel.org>
Sent: Thursday, August 28, 2008 10:49 PM
Subject: Re: Graphics support - ATI vs nVidia


>
>>
>> nVidia stopped tracking ia64 at least a couple of years ago ... so their
>> closed driver is only usable on old kernels.
>>
>> -Tony
>> --
>
>
> Thanks for that, I now have the ZX-6000 and am using on the supplied 
> Radeon 7000 (RV100) card with Ubuntu 8.04 (tried Debian too). Ive been 
> trying to get DRI working and have been digging through several years 
> worth of mailing lists on the various flat out bugs with X on the IA64 
> platform (which now should be fixed I hope!) and other issues. I have got 
> it to the point that AGP is working but Im getting a very basic error as 
> seen in glxinfo:
>
> libGL error: failed to open DRM: Operation not permitted
> libGL error: reverting to (slow) indirect rendering
>
>
> Usually this is just a permissions issue which is cured by adding:
>
> Section "DRI"
>    Mode  0666
> EndSection
>
>
> to Xorg.conf. I have tried that (also tried lowercase) and it just doesnt 
> work, makes no difference. Does anyone have any input or even just 
> assurance that DRI does indeed work, somewhere and somehow on someones 
> IA64?
>
>
> Alan

Just to update my own email, I upgraded to Ubuntu Intrepid Ibex (Alpha 4 and 
now 5) which includes Xorg 1.5 and new Radeon drivers. It now works "out of 
the box". I had tried Ubuntu 7.04 and 8.04, several Kernel versions and DRM 
changes, this is the first time it worked which would make it appear to be 
some sort of Xorg issue. 

