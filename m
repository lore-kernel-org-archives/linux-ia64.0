From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 19 May 2003 17:13:21 +0000
Subject: Re: [Linux-ia64] offsets.h generation
Message-Id: <marc-linux-ia64-105590723705946@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705941@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705941@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 19, 2003 at 02:30:57PM +1000, Peter Chubb wrote:
Content-Description: message body text
> 
> At present, if you change something that means offsets.h should be
> regenerated, the automatic dependencies mechanism doesn't do it.
> 
> Herewith a patch that adds proper dependency generation for 
>  printoffsets.s (and hence offsets.h)

I agree with the intention, but not the solution.
Other architectures generate a .s file from a .c file, and
filechk_gen-asm-offsets in the top-level Makefile is used to retreive
the asm offset parameters.

In this way you use the kbuild mecanishm to find dependencies,
and ia64 shift to do it the same way as other architectures.
See i386, sparc and other for a template how to do it.
Note that most of the architectures list too much dependencies
in the arch specific makefile. I will clean that up sometime.

Would you mind trying to look into this solution?

	Sam

