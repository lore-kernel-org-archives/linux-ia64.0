From: "Kotian, Deepak" <Deepak.Kotian@patni.com>
Date: Thu, 12 Feb 2004 03:53:09 +0000
Subject: RE: Query regarding Itanium (Mapping of register values)
Message-Id: <374639AB1012AA4C840022842AA95BC2013AE5DE@ruby.patni.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <374639AB1012AA4C840022842AA95BC20138E3FC@ruby.patni.com>
In-Reply-To: <374639AB1012AA4C840022842AA95BC20138E3FC@ruby.patni.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks David,
gdb uses gregset structure, could you please
provide a link in gdb source, because we 
need something like gdb core analysis.

Thanks and Regards
Deepak



-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Thursday, February 12, 2004 1:32 AM
To: Kotian, Deepak
Cc: linux-ia64@vger.kernel.org
Subject: Re: Query regarding Itanium (Mapping of register values)


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
