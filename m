From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Thu, 26 Dec 2002 06:07:11 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.52)
Message-Id: <marc-linux-ia64-105590709805629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Please apply this patch for discontigmem.
I made sure NUMA kernel worked fine with the patch
on 16way Itanium machine.

Thanks,
Kimi

*** arch/ia64/mm/init.c.org     Thu Dec 26 11:46:44 2002
--- arch/ia64/mm/init.c Thu Dec 26 14:52:57 2002
***************
*** 501,508 ****
        extern void discontig_paging_init(void);

        discontig_paging_init();
-
-       num_dma_physpages = 0;
        efi_memmap_walk(count_pages, &num_physpages);
  }
  #else /* !CONFIG_DISCONTIGMEM */
--- 501,506 ----


On Sat, 21 Dec 2002 01:00:09 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> A new ia64 patch is available at:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5
> 
> in file linux-2.5.52-ia64-021221.diff.gz.

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


