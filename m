From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Jun 2003 18:01:30 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613212216837@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Jun 2003 19:47:44 +0200, Sam Ravnborg <sam@ravnborg.org> said:

  Sam> diff -Nru a/arch/ia64/lib/Makefile b/arch/ia64/lib/Makefile
  Sam> --- a/arch/ia64/lib/Makefile    Thu Jun 19 14:19:14 2003
  Sam> +++ b/arch/ia64/lib/Makefile    Thu Jun 19 14:19:14 2003
  Sam> @@ -13,6 +13,12 @@
  Sam> lib-$(CONFIG_MCKINLEY) += copy_page_mck.o memcpy_mck.o
  Sam> lib-$(CONFIG_PERFMON)  += carta_random.o

  Sam> +ifeq ($(CONFIG_MD_RAID5),m)
  Sam> +       lib-y += xor.o
  Sam> +else
  Sam> +       lib-$(CONFIG_MD_RAID5)  += xor.o
  Sam> +endif

  Sam> No need for this ifeq ....
  Sam> lib-m should work as well as lib-y.
  Sam> If this is not the case then let me know - I will fix kbuild then.

  Sam> lib-m is actually documented!

I don't use RAID5 myself.  Can someone else test this and send me a
patch if it works?


  Sam> diff -Nru a/usr/Makefile b/usr/Makefile
  Sam> ....
  Sam> +$(obj)/initramfs_data.S: $(obj)/initramfs_data.cpio.gz
  Sam> +       echo '.section ".init.ramfs", "a"' > $@
  Sam> +       od -v -An -t x1 -w8 $^ | cut -c2- | sed -e s"/ /,0x/g" -e s"/^/.byte 0x"/ >> $@

  Sam> Will .incbin really replace the above magic?

It should.  The ony thing the above commands do is to convert
initramfs_data.cpio.gz into a hexdump which can then be assembled.

	--david
