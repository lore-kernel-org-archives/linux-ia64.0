From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 09 Nov 2005 15:24:47 +0000
Subject: Re: Montecito processor family
Message-Id: <20051109152447.GC27540@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 09, 2005 at 10:54:45PM +0900, Takayoshi Kochi wrote:
> I see that nothing has happend to Montecito's family name
> in both Linus' and Tony's tree since then.
> 
> Is adding 'Itanium 2' for case 0x20 enough or do we need
> something different?
> 
> Intel people may want to decide what it should be, according to
> their marketing/branding plan ;)

I'm sure they're having trouble getting that patch through Intel legal ;-)

Maybe we could put in a patch temporarily that calls it "Montecito",
then Intel can patch it to whatever the official marketing name is
upon release?

I'm not quite sure why we're so allergic to using the codenames in the
ia64 port.  I mean, look at arch/i386/kernel/cpu/intel.c
