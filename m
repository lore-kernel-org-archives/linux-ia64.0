From: Keith Owens <kaos@sgi.com>
Date: Tue, 25 Feb 2003 01:53:35 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805927@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805925@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805925@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 24 Feb 2003 17:42:48 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Tue, 25 Feb 2003 11:24:35 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> -    sal_log_mod_error_info_t    cache_check_info[16];
>  Keith> -    sal_log_mod_error_info_t    tlb_check_info[16];
>  Keith> -    sal_log_mod_error_info_t    bus_check_info[16];
>  Keith> -    sal_log_mod_error_info_t    reg_file_check_info[16];
>  Keith> -    sal_log_mod_error_info_t    ms_check_info[16];
>  Keith> +    sal_log_mod_error_info_t    cache_check_info[0];
>  Keith> +    sal_log_mod_error_info_t    tlb_check_info[0];
>  Keith> +    sal_log_mod_error_info_t    bus_check_info[0];
>  Keith> +    sal_log_mod_error_info_t    reg_file_check_info[0];
>  Keith> +    sal_log_mod_error_info_t    ms_check_info[0];
>
>Somehow I doubt a declaration of this form is a good idea.  If the
>records are all variable length, wouldn't it be saner to just declare
>this with something along the lines of:
>
>  Keith> +    sal_log_mod_error_info_t    check_info[0];
>
>and then provide separate macros to access the indiviual portions?

Either works, but nobody really cares about the various *check_info
sections.  What we care about is the processor static data that comes
after these sections and is addressed via the new function.  This was
the minimal change to correctly access the processor static data, it is
a one line change to mca.c.

Replacing the individual *check_info[0] sections with a single
check_info[0] means more changes to mca.c to use the new names.  It
also diverges from the SAL specification which lists the individual
fields.  Since the end result would be exactly the same as the existing
code, I went for the minimal change and kept SAL documentation
compatibility.  Blame the SAL docs, I do ;).


