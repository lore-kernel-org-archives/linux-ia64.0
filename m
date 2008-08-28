From: "A. Devine" <devine@dna.ie>
Date: Thu, 28 Aug 2008 21:49:19 +0000
Subject: Re: Graphics support - ATI vs nVidia
Message-Id: <14A8A24FDEB84984B30DFFC777C09704@kodax64>
List-Id: <linux-ia64.vger.kernel.org>
References: <7C4B5C8349AD4AC082AD250928FB330D@kodax64>
In-Reply-To: <7C4B5C8349AD4AC082AD250928FB330D@kodax64>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>
> nVidia stopped tracking ia64 at least a couple of years ago ... so their
> closed driver is only usable on old kernels.
>
> -Tony
> --


Thanks for that, I now have the ZX-6000 and am using on the supplied Radeon 
7000 (RV100) card with Ubuntu 8.04 (tried Debian too). Ive been trying to 
get DRI working and have been digging through several years worth of mailing 
lists on the various flat out bugs with X on the IA64 platform (which now 
should be fixed I hope!) and other issues. I have got it to the point that 
AGP is working but Im getting a very basic error as seen in glxinfo:

 libGL error: failed to open DRM: Operation not permitted
 libGL error: reverting to (slow) indirect rendering


Usually this is just a permissions issue which is cured by adding:

Section "DRI"
    Mode  0666
EndSection


to Xorg.conf. I have tried that (also tried lowercase) and it just doesnt 
work, makes no difference. Does anyone have any input or even just assurance 
that DRI does indeed work, somewhere and somehow on someones IA64?


Alan 

