From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 16 Oct 2003 23:20:33 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106634674805456@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Oct 2003 12:29:58 -0700, 
Grant Grundler <iod00d@hp.com> wrote:
>CONFIG_CRYPTO requires asm/kmaps_types.h.
>patch below clones kmap_types.h from asm-i386.

That is an error in crypto/internal.h.  Nothing should include
asm/kmap_types.h directly, they should include linux/highmem.h and let
that decide if the arch needs kmap or not.

