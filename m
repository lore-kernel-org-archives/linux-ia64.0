From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jan 2004 06:06:53 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for
Message-Id: <16407.20861.415243.849317@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
	<20040120090004.48995f2a.akpm@osdl.org>
	<16401.57298.175645.749468@napali.hpl.hp.com>
	<16402.19894.686335.695215@cargo.ozlabs.ibm.com>
	<16405.41953.344071.456754@napali.hpl.hp.com>
	<16406.10170.911012.262682@cargo.ozlabs.ibm.com>
	<16406.36741.510353.456578@napali.hpl.hp.com>
	<16406.63734.400759.452955@cargo.ozlabs.ibm.com>
In-Reply-To: <16406.63734.400759.452955@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Mackerras <paulus@samba.org>
Cc: davidm@hpl.hp.com, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@trained-monkey.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Jan 2004 10:49:10 +1100, Paul Mackerras <paulus@samba.org> said:

  Paul> I really don't like the uglification of lib/extable.c.

I disagree about this being an uglification.  But beauty is obviously
in the eye of the beholder...

Anyhow, you clearly feel _much_ stronger about this particular issue
than I do and I haven't heard much from Andrew, so I'll make a local
version of sort_extable() for now.  If someone cares about
resurrecting a generic version, they can do that later on.

	--david
