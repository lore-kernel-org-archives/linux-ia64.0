From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 22:47:02 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590723705547@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805925@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805925@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 24 February 2003 5:24 pm, Keith Owens wrote:
> The fr entries in struct sal_processor_static_info are 16 bytes wide
> but may not start on a 16 byte boundary in the sal record (it depends
> on the size of min_state).  Stop gcc from assuming that the fr entries
> are 16 byte aligned.
> 
> This was misaligning the fr records within sal_processor_static_info.
> In addition, because gcc thought that sal_processor_static_info
> contained a 16 byte field, sal_processor_static_info was being forced
> to 16 byte alignment within struct err_rec, destroying the mapping of
> the sal error record (preceding sal record header is only 40 bytes).
> 
> Within sal_log_processor_info, the sal_log_mod_error_info_t entries are
> fixed size but have a variable number of entries.  Change the
> definition from 16 (max) to 0 entries and add a function to calculate
> the address of the processor static info within sal_log_processor_info,
> based on what sal actually supplied.  Use that function in
> ia64_init_handler() to get the min_state data.
> 
> Against 2.4.20-ia64-021210.

I applied the patch from 2.5 to 2.4 as well.

