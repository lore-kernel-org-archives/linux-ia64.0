From: Vaibhav Sharma <vaibhav.sh@gmail.com>
Date: Sun, 06 Feb 2005 06:21:02 +0000
Subject: Re: IA64 memory
Message-Id: <851caabb050205220941abfd2b@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
To: linux-ia64@vger.kernel.org

hi, 

Thanks for the reply again.

Actually, my task requires me to modify the available physical memory.
I was trying to locate the place where the kernel stores the amount of
memory. Is this value stored in ia64_boot_param structure..?..If I am
wrong, please so tell, and whether that there is some other place
where this value is stored?

I have not tried the elilo sources to locate the structure.  
I tried to locate the structure in the kernel sources, but i couldn't
find the place where this structure is initialized, or where the
particular elements of the data structure are asigned values. As you
told, the  boot param structure is set up by elilo. I wanted to know
that when the EFI comes into play..
Is it that elilo reads the values from EFI?
Also, i wanted to ask that whether EFI is stored in memory, so that it
is accessible to the kernel sources?

Please do reply...
---
Vaibhav

On Thu, 3 Feb 2005 18:31:36 -0800, David Mosberger
<davidm@napali.hpl.hp.com> wrote:
> >>>>> On Thu, 3 Feb 2005 12:33:40 +0530, Vaibhav Sharma <vaibhav.sh@gmail.com> said:
> 
>  Vaibhav> Hi, Thanks a lot for a quick response, I appreciate.  If
>  Vaibhav> you could only help me out a little more $,1s&(B.
> 
>  Vaibhav> See, I need to change some of the boot parameters as
>  Vaibhav> read/seen by the kernel. Once these parameters have been
>  Vaibhav> setup by elilo, the Kernel must read it from these
>  Vaibhav> predefined areas in memory, into some of its variables. I
>  Vaibhav> need to understand where this reading part happens in the
>  Vaibhav> kernel. This is where I want to modify the resources, for
>  Vaibhav> future use by the kernel !! I don't want to touch the elilo
>  Vaibhav> source, only the kernel.
> 
> Why not grep the sources for ia64_boot_param?
> 
>        --david
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Vaibhav Sharma.
