From: Arjan van de Ven <arjan@infradead.org>
Date: Sat, 08 Jul 2006 06:42:43 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1152340963.3120.0.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>
	 <yq04py4i9p7.fsf@jaguar.mkp.net>
	 <1151578928.23785.0.camel@localhost.localdomain> <44A3AFFB.2000203@sgi.com>
	 <1151578513.3122.22.camel@laptopd505.fenrus.org>
	 <20060708001427.GA723842@sgi.com>
In-Reply-To: <20060708001427.GA723842@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Higdon <jeremy@sgi.com>
Cc: Jes Sorensen <jes@sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>



> So does i386 convert the return value of the times(2) call to user
> hertz?  On IA64, it returns the value in internal clock ticks, and
> then when a program uses the value in param.h, it gets it wrong now,
> because internal HZ is now 250.
> 
> So is times() is broken in IA64, or is this an exception to Alan's
> statement?

yes it's broken; it needs to convert it to the original HZ (1024) and
make the sysconf() function also return 1024


