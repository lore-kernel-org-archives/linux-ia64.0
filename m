From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 23 Oct 2003 04:56:57 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106688503531385@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian,

Thanks for tracking this down & the patch.  I applied it now.

	--david

>>>>> On Thu, 23 Oct 2003 11:52:30 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> Maybe just change it and add something like 

  Ian> Even though this is put with __special_page_section which is given
  Ian> attributes "ax" (head.S), gas will match anything with a prefix
  Ian> '.data.' as a data special section.  Thus to stop unnecessary warning
  Ian> about changing attributes, we use the .data section standard
  Ian> attributes "aw" when creating gate-data.o

  Ian> to the changelog?

  Ian> -i
  Ian> ianw@gelato.unsw.edu.au
  Ian> http://www.gelato.unsw.edu.au
  Ian> === gate-data.S 1.1 vs edited ==  Ian> --- 1.1/arch/ia64/kernel/gate-data.S	Thu Jun 12 18:09:19 2003
  Ian> +++ edited/gate-data.S	Thu Oct 23 11:51:03 2003
  Ian> @@ -1,3 +1,3 @@
  Ian> -	.section .data.gate, "ax"
  Ian> +	.section .data.gate, "aw"
 
  Ian> .incbin "arch/ia64/kernel/gate.so"
