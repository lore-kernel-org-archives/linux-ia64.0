From: "McCaffity, Ray" <ray.mccaffity@wcg.com>
Date: Wed, 25 Apr 2001 17:00:32 +0000
Subject: RE: [Linux-ia64] Re: New gnu-efi package and new boot loader avai
Message-Id: <marc-linux-ia64-105590693005464@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005448@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005448@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This doesn't seem to be hurting anything as far as I can tell, but
is there a way to fix this?

Warning: EFI system table major version mismatch: got 1.02, expected 0.92
EFI v1.02 by INTEL: SALsystab=0x7ff266e0 ACPI=0x7fe99cc8 ACPI 2.0=0x7fe99f00
MPS
=0x7ffd0000 SMBIOS=0xf00a0

-----Original Message-----
From: Stephane Eranian [mailto:eranian@frankl.hpl.hp.com]
Sent: Friday, April 20, 2001 7:27 PM
To: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Re: New gnu-efi package and new boot loader
available


Bill,

> A few ELILO patches - one bugfix:
> - elilo-makefile.patch
>   Tweaks the dependency rules in the Makefile so it will rebuild OK if
>   you change one file.

Good.

>   
> one behavior change:
> - elilo-image.patch
>   Appends extra command-line parameters to any image parameters, instead
>   of overriding all of them. Overriding things like 'ro' or 'root='
>   should still work, AFAIK.

I did not check how LILO was behaving for comparison and you just gave me
the
answer.

>   
> and two things catering to my personal preferences :) :
> - elilo-query.patch
>   Makes the '-q' behavior the default, and adds a '-Q' to turn on
querying.
> - elilo-verbosity.patch
>   Wraps many messages with 'if (elilo_opt.verbose)'; also
>   turns off the timeout if an image was specified on the command line
> 
Fine.

I will integrate your patches into the new version of ELILO. I'll try to
remember
to protect Print() with the verbose test. Also the new ELILO will have a
config
file parsing that will be much cleaner and closer to the PC LILO. I adapted
the code and remove some options which did not make sense.  I just need to
integrate it to ELILO now. The new ELILO will also have netbooting support.

Also for now DO NOT USE THE initrd fix I submitted a few days back. We are
moving allocations around between ELILO and the kernel and at this point we
don't have a final answer. Probably the new kernel and ELILO will have the
right
stuff and changes will be transparent to users. I am also planning on
separating 
ELILO from the rest of the gnu-efi package because they don't evolve at the 
same pace.

Thanks for your contributions.


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

