From: John Byrne <john.l.byrne@hp.com>
Date: Wed, 13 Nov 2002 21:32:52 +0000
Subject: Re: [Linux-ia64] cannot boot kernel.org 2.4.19+ia64 patches on an
Message-Id: <marc-linux-ia64-105590709805412@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805409@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805409@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Message: 5
> Date: Wed, 13 Nov 2002 10:58:56 +0100
> From: "Cabaniols, Sebastien" <Sebastien.Cabaniols@hp.com>
> To: <linux-ia64@linuxia64.org>
> Subject: [Linux-ia64] cannot boot kernel.org 2.4.19+ia64 patches on an rx2600
> 
> Hello list,
> 
> I am trying hard to make a stock 2.4.19 patched linux-ia64 patch to boot > an rx2600 (zx1 two ways HP machine) boot.
> 
> Did some of you managed to boot such a kernel ?
> 
> 
> I am currently running the 2.4.18-e12 from redhat (into the advanced > server edition), I managed to recompile

Advanced Workstation?

> it and run it. I tried to get the .config file from this one, did make > oldconfig with my 2.4.19 (stock) + IA64 patches
> and it does not boot (no message on the console... nothing)
> 
> 
> Thanks for any help/suggestions.
> 
> 
> I can provide the .config on demand.
> 
> Sebastien Cabaniols
> HP  Annecy
> France
> 
> 
> -

I get this list as a digest so I am sorry if this is redeundant.

I was in a similar state trying to boot 2.4.18 on a rx2600 with the 
RedHat config file from the Advanced Workstation kernel. I eventually 
succeeded by adding the latest ACPI patch from apci.sourceforge.net. I 
then hit an incompatibility between that patch and the zx1 support, but 
that appears to be fixed in 
2.4.19+linux-2.4.19-ia64-020821.diff+acpi-20020918-2.4.19-ia64-020821.diff. 
So I'd try the applying the acpi patch unless someone else has better 
advice.

Good luck,

John Byrne



