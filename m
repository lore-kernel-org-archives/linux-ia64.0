From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Feb 2003 01:42:48 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805926@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805925@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805925@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Feb 2003 11:24:35 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> -    sal_log_mod_error_info_t    cache_check_info[16];
  Keith> -    sal_log_mod_error_info_t    tlb_check_info[16];
  Keith> -    sal_log_mod_error_info_t    bus_check_info[16];
  Keith> -    sal_log_mod_error_info_t    reg_file_check_info[16];
  Keith> -    sal_log_mod_error_info_t    ms_check_info[16];
  Keith> +    sal_log_mod_error_info_t    cache_check_info[0];
  Keith> +    sal_log_mod_error_info_t    tlb_check_info[0];
  Keith> +    sal_log_mod_error_info_t    bus_check_info[0];
  Keith> +    sal_log_mod_error_info_t    reg_file_check_info[0];
  Keith> +    sal_log_mod_error_info_t    ms_check_info[0];

Somehow I doubt a declaration of this form is a good idea.  If the
records are all variable length, wouldn't it be saner to just declare
this with something along the lines of:

  Keith> +    sal_log_mod_error_info_t    check_info[0];

and then provide separate macros to access the indiviual portions?

	--david

