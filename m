From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 16 Dec 2002 17:41:18 +0000
Subject: Re: [Linux-ia64] can linux support intel 870 chipset now?
Message-Id: <marc-linux-ia64-105590709805571@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805565@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805565@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hi all, I am new to this maillist. I do not know if
> linux can support intel 870 chipset now? If can,
> where can I download the kernel for it? If someone
> knows, please help me. Thanks in advance!

Download the base kernel from:

    ftp://ftp.kernel.org/pub/linux/kernel/v2.4/linux-2.4.20.tar.bz2

and the IA64 patch from:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.20-ia64-021210.diff.gz

This should support the Intel 870 chipset, though I don't have such
a machine and can't test it directly.
-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux and Open Source Lab
Hewlett-Packard Company

