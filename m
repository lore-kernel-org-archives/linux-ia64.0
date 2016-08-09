From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 09 Aug 2016 16:09:07 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <1470758947.2299.47.camel@HansenPartnership.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	 <20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
In-Reply-To: <20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xen

On Tue, 2016-08-09 at 15:24 +0100, One Thousand Gnomes wrote:
> > table development go under copyleft-next, Rusty recently asked for=20
> > code to go in prior to the license tag being added denoting this=20
> > license as GPL-compatible [3] -- I had noted in the patch=20
> > submission which annotated copyleft-next's compatibility to GPLv2=20
> > that copyleft-next is the license of choice for ongoing kernel=20
> > development on my end [4]. If this is objectionable I'm happy to=20
> > change it to GPLv2 however I'd like a reason provided as I've gone=20
> > through all possible channels to ensure this is kosher, including
> > vetting by 3 attorneys now, 2 at SUSE.
>=20
> You don't need a new tag, you can use "GPL" or "GPL and additional
> rights". In fact you don't want any other tag because when combined
>  with the kernel it is GPLv2 anyway because the only way the two are=20
> fully compatible is for the kernel community to license the derived=20
> work under the GPL.

This is the module tag ... it says what licence the module is under,
not the licence for the module combined with the kernel, which is
always GPLv2 because the stricter licence rules.

> The second reason you must use the GPL or GPL with additional tag is
> clause 8. We don't want anyone to create a module under your licence,
> claim it is "open source" then fifteen years later release the module=20
> in binary only form still with a tag saying "copyleft-next" which we
> treat as GPL compatible. It's the same reason we don't have a BSD tag=20
> but use "GPL with additional rights" to stop abuse of the module
> tags.

I don't follow you here.  We do have separate Dual licence tags. Dual
BSD/GPL allows me to do this today, without waiting fifteen years.  I
think you're conflating two issues:

   1. The licence of the actual module, which must be compatible with the
      kernel to do an insmod. =C2=A0This is actually what MODULE_LICENSE
      declares
   2. The conditions the creation of the combined work imposes on me

It's the latter, even in the case of Dual BSD/GPL which still requires
me to release source code, so the combination with the kernel forces
GPL conditions even in the case of a BSD module (which is otherwise
compatible) and even after 15 years of this copyleft-next.

The point is: I can create a pure BSD module.  You can pick it up and
put it into the kernel source as Dual BSD/GPL, because BSD allows this,
but I'm still free to create binary only versions under BSD (as long as
they're for something other than inserting into Linux).  However, if I
want my binary only modules to be combined with Linux, I have to follow
GPLv2 compliance because GPLv2 becomes the ruling licence of the
combination.  The same would apply to this copyleft-next, even after 15
years.

> However you need to clarify the licence first I think. Linux is=20
> GPLv2, your document only allows use of GPL with "GPL" works - not=20
> GPL v2 works ?

A reasonable person would take GPL to mean any version of GPL.

> As PS: btw your licence is kind of weird. I can combine it with GPL=20
> work, make it GPL therefore, and then use the GPL rights to remove=20
> the bits I added thereby meaning I have your exact original work=20
> under the GPL. Not sure how it's intended to work ?

What you describe is how it's always worked.  You may always distribute
a compatibly licensed piece of code under the stricter licence.=20
 Additional permissions are always strippable in GPLv3 terms.

> It would also be good if someone clarified whether 6 and 7 are=20
> intended to combine so you can take contributed patches and put them=20
> in your own proprietary version. As a non-lawyer the intent is not
> clear at all.

The US copyright office defines a copyright work as anything which is
"an original work of authorship fixed in any tangible medium of
expression".  That means any change to an existing work (i.e. by a
patch) which contains enough originality to make the changed work
distinct from the old work is ipso facto a new work.  under copyright
-next this new work has a sunset 15 years from its creation by
combination, not 15 years from the original.  This means a constantly
updated work never sunsets.  Sure, you can go back 15 years and claim
the code at that time has passed into the public domain but you can't
do that if you also want the benefit of later changes.

James

