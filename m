From: Robin Holt <holt@sgi.com>
Date: Wed, 26 Feb 2003 21:15:03 +0000
Subject: Re: [Linux-ia64] nfsroot on Linux/ia64
Message-Id: <marc-linux-ia64-105590709805934@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805932@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805932@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 26 Feb 2003, Erik Jacobson wrote:

> Has anyone tried using nfsroot (cf. "Documentation/nfsroot.txt")
> on Linux/ia64 to run "diskless"?  I expect that it will work fine
> but I need to do some testing where nfsroot may prove
> useful and hope to avoid investing a lot of energy if
> someone else has tried it and it, for some reason,
> doesn't work.

I have used it.  The one issue that I am running into is the ipconfig.o 
(CONFIG_IP_PNP option) doesn't work as a loadable module.  I am in the 
process of modifying nfsroot.c, ipconfig.c and mnt_clnt.c to allow 
ipconfig to be built as a module and verify it works.  I am working with 
2.4.19 with the ia64 and discontig patches applied.

If you have questions, please direct them to me as I rarely read mailing
list.

Thanks,
Robin Holt

> 
> Note that I know that booting diskless has been tried
> successfully... I'm interested specifically in an NFS-mounted
> root disk.
> 
> Thanks,
> Dan Magenheimer
> HP Labs Fort Collins
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

-- 


