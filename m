From: Dave Anderson <anderson@redhat.com>
Date: Tue, 30 Jul 2002 14:03:49 +0000
Subject: [Linux-ia64] Re: insmod bug causes kernel unwind failures for module text
Message-Id: <marc-linux-ia64-105590701905855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905853@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905853@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> if (!mod_bound(archdata->segment_base, 0, mod))
> {
>       printk(KERN_ERR "module_arch_init: archdata->unw_table out of
bounds.\n");
>       return 1;
> }

BTW, the error message is apparently a cut-and-paste error in the kernel code...

Dave Anderson




