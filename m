From: Nick Clifton <nickc@redhat.com>
Date: Fri, 24 Oct 2003 10:07:22 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106699054401555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi H.J.

>> I figured out why (sorry if it's obvious); gas matches anything with
>> prefix '.data.' as a data special section and flags it as 'SHF_ALLOC +
>> SHF_WRITE' as per ELF [*].  Issuing 
>> 
>> .section .data.gate, "ax"
>> 
>> thus conflicts as it's assumed to be an extension of a .data section.

> 2003-10-21  H.J. Lu  <hongjiu.lu@intel.com>
>
> 	* config/obj-elf.c (obj_elf_change_section): Use specified
> 	section attributes.

Approved - with a few minor changes, see below - please apply.

Cheers
        Nick

        
> +  bfd_boolean override = FALSE;

[optional]: This variable could be moved inside the if statement
starting at line 672, localizing it, if the statement was changed to:

  if (old_sec = NULL)
    {
      bfd_boolean override = FALSE;

      if (attr & ~ ssect->attr)
        {
        ...
        }

      if (!override)
	attr |= ssect->attr;
  }      

I feel that the code looks neater this way.

     
>  		   && (attr &~ ssect->attr &~ SHF_MERGE &~ SHF_STRINGS) = 0)

I would appreciate it if you could add a space between the '&' and the
'~'.  These are separate operators and should not be juxtaposed like
that.  I know that this is not part of your original patch, but since
we are modifying this area of code, I think that it would be a good
idea to clean this up.


> +	      as_warn (_("setting incorrect section attributes for %s"),
> +		       name);
> +	      override = TRUE;

Since the new attributes are going to be ignored, we should change the
warning message appropriately.  Something like:

	      as_warn (_("ignoring setting of incorrect section attributes for %s"),

