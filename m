From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 17:17:43 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16879.59319.867293.363750@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 20 Jan 2005 04:03:19 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> What about real memory and mapping it uncached? Do we need to
  Jes> play the same trick before allowing it to be mapped uncached?

It needs to be done on a granule-boundary, too, yes.

  Jes> Trying to map real memory uncached was what made me stumble
  Jes> upon the PREFETCH_VISIBILITY limitation in the PAL code.

I assume you're using this as part of the procedure outlined in
Section 4.4.11.2 of IASD v2 "Physical Addressing Attribute
Transition", right?

	--david
