From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 18:54:34 +0000
Subject: Re: [Linux-ia64] 2.5.72 bss initializers
Message-Id: <marc-linux-ia64-105639453217618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105637930631805@msgid-missing>
In-Reply-To: <marc-linux-ia64-105637930631805@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 10:15:03 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> No need to explicitly zero out global pointers in efi.c and efivars.c

I applied this now.  In the future _please_ send patches which apply
with "patch -p1".

Thanks,

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
