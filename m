From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Oct 2003 20:23:00 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106633599727193@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 16, 2003 at 08:40:22PM +0100, Matthew Wilcox wrote:
> Cloning kmap_types from i386 is a pretty bad idea since that architecture
> actually supports highmem.  Better to clone from an arch which has no
> support for highmem such as ARM.

uhm, I would, but...
grundler@gsyprf3:/usr/src/linux-ia64-2.4-orig$ ls -l include/asm-arm/kma*
ls: include/asm-arm/kma*: No such file or directory

Anyway, given ia64 doesn't otherwise need kmap_types.h, I suspect it
doesn't matter. Except that it's misleading. Maybe a stripped down version
of the file would be better.

grant
