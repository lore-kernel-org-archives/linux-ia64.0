From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Wed, 12 Jul 2006 02:02:37 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <ed5aea430607111902i91b9e92s784ce8d2103f1b4e@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>
	 <1151578928.23785.0.camel@localhost.localdomain>
	 <44A3AFFB.2000203@sgi.com>
	 <1151578513.3122.22.camel@laptopd505.fenrus.org>
	 <20060708001427.GA723842@sgi.com>
	 <1152340963.3120.0.camel@laptopd505.fenrus.org>
	 <ed5aea430607080607u67aeb05di963243c0e653e4f0@mail.gmail.com>
	 <20060710202228.GA732959@sgi.com>
	 <ed5aea430607102001g514bfa97jf82c25a038e9c436@mail.gmail.com>
	 <20060711183754.GB734242@sgi.com>
In-Reply-To: <20060711183754.GB734242@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Higdon <jeremy@sgi.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Jes Sorensen <jes@sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>

On 7/11/06, Jeremy Higdon <jeremy@sgi.com> wrote:

> Okay.  So what do you think about changing the value in param.h from
> 1024, so that it matches the new common value of 250, or is it best
> just to leave it at 1024 and let applications that use it get the wrong
> result?

In my opinion, HZ needs to be a constant, since otherwise you could
break perfectly fine existing code (e.g., code which statically
initializes a variable with HZ and then picks up the correct frequency
from sysconf) and if you have to pick a particular constant, it seems
reasonable to me to pick the most commonly used frequency (which
appears to be 250Hz at the moment).

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
