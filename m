From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 23 Oct 2003 01:52:30 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="LpQ9ahxlCli8rRTG"
Message-Id: <marc-linux-ia64-106687401324479@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
To: linux-ia64@vger.kernel.org


--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 22, 2003 at 11:08:20AM -0700, David Mosberger wrote:
>   Ian> Issuing
>   Ian> .section .data.gate, "ax"
>   Ian> thus conflicts as it's assumed to be an extension of a .data
>   Ian> section.

> I'm not sure why I put "ax" there---it was most likely a left-over
> from earlier experimentation.  So I think the fix is to change "ax"
> to "aw" (the data isn't really writable, but to avoid losing more
> memory to page-alignment, it's better to keep the gate page in the
> writeable data section).  Do you want to try this?

Yep, this stops the warning and everything looks fine.  I'd say you
put it there because it gets lumped with

        .section __special_page_section,"ax"

from head.S, so in the end the whole thing ends up with AWX.

  [21] .data.page_aligne PROGBITS         a000000100610000  00620000
       0000000000008d50  0000000000000000 WAX       0     0     1

You're of course right about wasting memory with a separate section, I
didn't think of that. 

Maybe just change it and add something like 

Even though this is put with __special_page_section which is given
attributes "ax" (head.S), gas will match anything with a prefix
'.data.' as a data special section.  Thus to stop unnecessary warning
about changing attributes, we use the .data section standard
attributes "aw" when creating gate-data.o

to the changelog?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gate-data-aw.diff"

===== gate-data.S 1.1 vs edited =====
--- 1.1/arch/ia64/kernel/gate-data.S	Thu Jun 12 18:09:19 2003
+++ edited/gate-data.S	Thu Oct 23 11:51:03 2003
@@ -1,3 +1,3 @@
-	.section .data.gate, "ax"
+	.section .data.gate, "aw"
 
 	.incbin "arch/ia64/kernel/gate.so"

--LpQ9ahxlCli8rRTG--
