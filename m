From: Grant Grundler <iod00d@hp.com>
Date: Wed, 14 May 2003 15:41:23 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 14, 2003 at 02:29:00PM +0100, Matthew Wilcox wrote:
> But those HPUX systems were on PA which has PDC which can write to
> the disc.  The problem on ia64 is that EFI can't after the OS has started.

yup - I understood that. The "where to write" information getting
corrupted is the same problem regardless of where the driver code
to do the writes exists.

grant

