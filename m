From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Mon, 13 Oct 2003 05:36:02 +0000
Subject: RE: 2.6.0-Test5 booting problems on Itanium-1!
Message-Id: <marc-linux-ia64-106602273329399@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106569415603393@msgid-missing>
In-Reply-To: <marc-linux-ia64-106569415603393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Thu, Oct 09, 2003 at 03:37:44PM +0530, Ameya Mitragotri wrote:
> > 
> > I also tried to boot using a gzipped image (vmlinux.gz) but 
> i get an 
> > error "min_addr not page aligned"
> > 
> > Any suggestions will be really helpful.
> 
> I booted -test5 on my Big Sur box and used it for awhile, so 
> I'm pretty sure it works.  Did you forget to turn on VGA 
> console maybe?  You could also try turning on 
> CONFIG_EARLY_PRINTK in the 'Kernel Hacking' submenu to see if 
> that gets you any useful output.

1) The VGA console options are all ok.
2) I tried to compile with CONFIG_EARLY_PRINTK and
CONFIG_IA64_EARY_PRINTK.
   There were a lot of compilation problems and it dint get through.

I also tried the following:

AFAIK _start is the entry point to the IA64 kernel.
I found that the kernel vmlinux-2.4.0-0.99.11smp *which_boots* without
problems has a _start address = e000000000520000. This is also stored in
the 
Elf header of the file as Entry Point Address. (I used readelf to
confirm)

While the kernel which *I_am_trying_to_boot* vmlinux-2.6.0-test5 has
a _start address = a000000100010000. And the elf header shows Entry
Point Address
as 0x4010000. This means that this kernel will not load properly as the
boot loader
reads the elf file header and jumps to the Start Address (??).

My guess is that I'm missing some compiler / configuration options. Has
any body
faced this problem before? Any pointers will be really helpful.

Thanks
ameya  
