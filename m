From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Thu, 01 Jun 2000 21:26:31 +0000
Subject: Re: [Linux-ia64] initrd suport for ELI, kernel
Message-Id: <marc-linux-ia64-105590678205113@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205112@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205112@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 01, 2000, Bill Nottingham <notting@redhat.com> wrote:
> Here's some patches that add initrd support to ELI
> and the kernel. To use, simply add:
> 
> 	initrd=<some file>
> 	
> to your eli.cfg. The ELI code that loads the kernel is
> shamelessly copied from the kernel loading code. This
> currently loads the initrd directly after the kernel.

That's alright. I've checked the code into CVS.

> Current bugs:
>  - the kernel assumes the address passed to it for
>    the initrd is valid. We should probably check this.

A NULL check should be sufficient. Perhaps we should add a version field
to the boot structure so the kernel knows if the boot loader supports
certain fields and should thusly use them or not?

JE



