From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Thu, 10 Nov 2005 01:50:00 +0000
Subject: Re: Montecito processor family
Message-Id: <20051110.105000.112623152.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > I see that nothing has happend to Montecito's family name
> > in both Linus' and Tony's tree since then.
> > 
> > Is adding 'Itanium 2' for case 0x20 enough or do we need
> > something different?
> > 
> > Intel people may want to decide what it should be, according to
> > their marketing/branding plan ;)
> 
> I'm sure they're having trouble getting that patch through Intel legal ;-)
> 
> Maybe we could put in a patch temporarily that calls it "Montecito",
> then Intel can patch it to whatever the official marketing name is
> upon release?

IIRC the field once was "McKinley" for Itanium2 but later replaced with
"Itanium 2".  So this sounds ok.  But probably as no real application
depends on or relies on the field, I think we can display '32' as it
is until the 'official' name is given.

> I'm not quite sure why we're so allergic to using the codenames in the
> ia64 port.  I mean, look at arch/i386/kernel/cpu/intel.c

Maybe we can add 'codename' field in cpuinfo so that people can
recognize codename:marketing name correspondense, and we can
distinguish McKinley, Madison, Deerfield, ... (I don't remember all)
among Itanium2s ;)

---
Takayoshi Kochi
