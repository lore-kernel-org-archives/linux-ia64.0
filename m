From: Matthew Wilcox <willy@debian.org>
Date: Fri, 30 Apr 2004 18:23:13 +0000
Subject: Re: SAL PCI config space
Message-Id: <20040430182313.GU22558@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 30, 2004 at 11:04:44AM -0700, Luck, Tony wrote:
> >ia64_sal_pci_config_read() and ia64_sal_pci_config_write() use 
> >SAL_CALL(). This takes an IRQ-safe spinlock, but SAL 3.2 says that 
> >SAL_PCI_CONFIG_READ and SAL_PCI_CONFIG_WRITE are both MP-safe and
> >reentrant.  So is there any reason we shouldn't use SAL_CALL_REENTRANT?
> 
> Theoretically there might be older SAL implementations where these
> aren't re-entrant ... so to be really safe, you'd have to check that
> the SAL version is >= 3.2 before using the SAL_CALL_REENTRANT form.

Gack.  I went and dug up some older SAL specs.

SAL 3.1 is ambiguous.  On page 9-4, it says "Yes" under "Re-entrancy
requirement" for these calls, but then on 9-18 and 9-19, it says,
"Good programming practices dictate that indexed accesses to the
configuration space be serialized in order to be MP-safe."

(this seems rather looney to me.  how can you have something that's
reentrant but not MP-safe?  I think it's an unintended carry-over from
SAL 3.0)

SAL 3.0 states "SAL procedures are not re-entrant with respect to any
runtime service (including itself)."

So what's actually shipping in systems?  David's against runtime checks
due to some of the buggy firmware hp's managed to ship.  I agree with
him that it would have been much more sensible had the SAL spec specifid
new calls rather than changing the semantics of existing calls.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
