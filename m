From: Matthew Wilcox <willy@debian.org>
Date: Wed, 05 Nov 2003 17:30:57 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106805373412838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 05, 2003 at 09:14:08AM -0800, Alberto Munoz wrote:
> What implementation of the Itanium processor supports avoiding MCAs from
> lfetch or code fetch operations? I don't think Itanium 1 or 2 do this. How
> about Madison?

Oops, misunderstanding here.  Madison and Deerfield are also Itanium 2.
It's like Coppermine and Tualatin are both Pentium 3.  When the difference
is only cache size, die size, clock frequency and so on, they're not
going to change the number.  For bigger changes, they might ;-)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
