From: Grant Grundler <iod00d@hp.com>
Date: Fri, 17 Oct 2003 01:27:15 +0000
Subject: Re: type 95 for .text?
Message-Id: <marc-linux-ia64-106635404710748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634361902844@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634361902844@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 16, 2003 at 06:12:12PM -0700, Grant Grundler wrote:
> I just added that...sounds like bjorn should ignore my patch
> since the module isn't getting built correctly. *sigh*.

because arch/ia64/lib/Makefile defines it's own .S.o rule:
.S.o:
        $(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c $< -o $@

despite CONFIG_MD_RAID5=m and using:
obj-$(CONFIG_MD_RAID5) += xor.o

I get:
gcc -D__ASSEMBLY__ -D__KERNEL__ -I/usr/src/linux-ia64-2.4/include -mconstant-gp -c xor.S -o xor.o

Removing the .S.o rule gets me:
make[1]: Entering directory `/usr/src/linux-ia64-2.4/arch/ia64/lib'
gcc  -D__KERNEL__ -I/usr/src/linux-ia64-2.4/include  -c -o xor.o xor.S

But then "make compressed" dies.
I'll try adding a target just for xor.S:
xor.o:	xor.S
        $(CC) $(AFLAGS) -c $< -o $@

Bjorn, let me test this out and then submit another patch.

thanks keith!
grant
