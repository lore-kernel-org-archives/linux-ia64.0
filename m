From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 21 Jan 2005 09:00:11 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <yq0hdlb17j8.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 20 Jan 2005 04:03:19 -0500, Jes Sorensen <jes@wildopensource.com> said:
Jes> Trying to map real memory uncached was what made me stumble upon
Jes> the PREFETCH_VISIBILITY limitation in the PAL code.

David> I assume you're using this as part of the procedure outlined in
David> Section 4.4.11.2 of IASD v2 "Physical Addressing Attribute
David> Transition", right?

The section code named 'clear as pea soup'? ;-) Yes, thats exactly
where I ran into it.

Cheers,
Jes
