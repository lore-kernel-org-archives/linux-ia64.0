From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Jul 2002 23:59:48 +0000
Subject: Re: [Linux-ia64] [PATCH] arch/ia64/boot/Makefile
Message-Id: <marc-linux-ia64-105590701905827@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905825@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905825@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Jul 2002 16:51:11 -0700, "David N. Lombard" <david.lombard@mscsoftware.com> said:

  David.L> arch/ia64/boot/Makefile uses the macro TARGET without defining it.
  David.L> The attached patch corrects that.

  David.L> clean:
  David.L> -	rm -f $(TARGETS)
  David.L> +	rm -f bootloader $(OBJECTS)

This probably broke when TARGETS got replaced by targets-y.
Thanks for the patch.

	--david

