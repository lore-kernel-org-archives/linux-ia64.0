From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 24 May 2002 19:04:57 +0000
Subject: Re: [Linux-ia64] QLogic Fiber channel HBA support
Message-Id: <marc-linux-ia64-105590701905598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905597@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905597@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

mackey wrote:
> Does anyone know if the QLogic QLA2200F card is supported by ia64 linux?

Looks like the qla2x00 does support that series.
I've never tried it. But:
grundler <536>fgrep -l virt_to_bus drivers/scsi/ql*
drivers/scsi/qla1280.c
drivers/scsi/qla2x00.c

has me nervous. virt_to_bus is definitely obsolete and was
one of the things I had to fix in the megaraid driver despite
similar KERNEL_VERSION ifdefs for *most* usage.

> I am purchasing a Dell 7150 server and am considering an FC storage system.

I'm not convinced linux has a good FC story yet.
The disk racking systems are way over priced.
emulex has a closed source driver and cpqfc isn't tested
with many devices. Don't know where qlogic or LSI are
WRT to drivers and supported features. I'd be interested
in any summaries people are aware of.

grant

