From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 11 Feb 2004 20:02:01 +0000
Subject: Re: Query regarding Itanium (Mapping of register values)
Message-Id: <16426.35385.82820.511412@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <374639AB1012AA4C840022842AA95BC20138E3FC@ruby.patni.com>
In-Reply-To: <374639AB1012AA4C840022842AA95BC20138E3FC@ruby.patni.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Deepak,

The format is "documented" in the Linux source code (see
http://linux.bkbits.net:8080/linux-2.5/anno/arch/ia64/kernel/process.c@1.50
for example).  The comment in that file says:

	/*
	 * coredump format:
	 *	r0-r31
	 *	NaT bits (for r0-r31; bit N = 1 iff rN is a NaT)
	 *	predicate registers (p0-p63)
	 *	b0-b7
	 *	ip cfm user-mask
	 *	ar.rsc ar.bsp ar.bspstore ar.rnat
	 *	ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec
	 */

Hope this helps,

	--david
