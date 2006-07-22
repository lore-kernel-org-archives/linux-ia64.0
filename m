From: James E Wilson <wilson@tuliptree.org>
Date: Sat, 22 Jul 2006 03:34:32 +0000
Subject: Re: bogus gas error messages
Message-Id: <1153539271.26845.435.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430607211009l37cad6afj39cf70865a81d3ef@mail.gmail.com>
In-Reply-To: <ed5aea430607211009l37cad6afj39cf70865a81d3ef@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-07-21 at 10:09, David Mosberger-Tang wrote:
> These are bogus errors in my opinion and should be removed.  For
> example, we already commonly use "saves" to r0 to terminate the
> call-chain.  I'm seeing this with gas v2.17, but it may have been
> around for longer.

This was added by Jan Beulich of Novell on July 1, 2005.  He was fixing
inconsistencies between gas and ias, while trying to port a large body
of code from ias to gas.  So both IAS and the Intel Assembler Language
Guide say that r0/f0/f1 are not valid registers here.  However, the
Intel ALG does not prevent saves to r0.  It is only spillreg and
spillreg.p that aren't allowed to take a readonly register as an
operand.

There is similar language in the Software Conventions and Run-time
Architecure Guide.  In Appendix B, Unwind Descriptor Record Format,
section B.5, in the Format X2 description, it gives encodings for all
registers other than r0/f0/f1.  Looking at this, it is clear that r0 is
a problem here, because the obvious encoding for r0 is actually used by
the restorereg record type.

We can't support spillreg for r0, though we could for f0.  However, we
run the risk that SCRA may someday use the f0 encoding for something
else.  So it seems unwise to do this.

Jim


