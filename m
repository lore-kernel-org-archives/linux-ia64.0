From: Matthew Wilcox <willy@debian.org>
Date: Mon, 24 Mar 2003 12:50:32 +0000
Subject: Re: [Linux-ia64] Linux, Itanium and PA/RISC
Message-Id: <marc-linux-ia64-105590723705300@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705295@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 24, 2003 at 01:23:32PM +0100, Adriano Galano wrote:
> If IPF support PA-RISC mapping is not easy to "port" the PA/RISC Linux,
> excluding architectural changes in the chipset or booting process?

Why would you want to?  ia64 already has its own perfectly good Linux port.

> How HP/UX v 11.6 could be offer compatibility between PA/RISC and Itanium 2
> systems?

That's `11i v1.6'.  Quoting from
http://www.hp.com/products1/unix/operating/choice/hp-ux11i_details.html

	PA-RISC binary compatibility

  HP-UX 11i version 1.6 includes the Aries dynamic code translation
  technology as an integrated component. Aries is built on the close
  relationship between the PA-RISC and Intel Itanium instruction sets
  and provides binary compatibility for PA-RISC binaries on the Itanium
  processor family. Aries can be used where performance is not critical
  or where it is not possible to create a native Itanium processor
  family binary.

> How "exact" is the PA-RISC mapping on the IA-64 core?

Not particularly close.  If you look at the assembly language level,
there's a lot of similarities, but there's a lot of differences too.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

