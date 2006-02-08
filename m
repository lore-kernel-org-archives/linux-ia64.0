From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Feb 2006 18:35:57 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05A6DEE7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>, Adrian Bunk <bunk@stusta.de>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Adrian> Is this OK for you?

Jes> Not really, it helps a bit by selecting some things we know we need
Jes> for all GENERIC builds. True we can't make it bullet proof, but whats
Jes> there is better than removing it.

Which I think sums up why this is so contentious.  There is no right answer
here as the purpose of the GENERIC entry is rather vague and has been
interpreted differently by different people.  Mostly it is a convenience
entry that auto-selects a bunch of other config options, but there isn't
a single answer to what it should select, as different people have different
goals, so what might be convenient for one person would be a pain for
someone else.

The current set looks close ... perhaps PCI should be added as it isn't
likely to inconvenience anyone, but SMP is a lot further into murky territory
(some distributors like to use a UP kernel for installation ... so they
want a "generic" kernel, but don't need to worry about SMP ... there are few
places where SMP would be advantageous during install).

-Tony
