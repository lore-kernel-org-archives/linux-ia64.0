From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 02:35:38 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310234.k2V2Ysg28086@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301736580.2758@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 5:38 PM
> > Christoph Lameter wrote on Thursday, March 30, 2006 5:13 PM
> > > Then there will no barrier since clear_bit only has acquire semantics.
> > > This is a  bug in bit operations since smb_mb__before_clear_bit does
> > > not work as documentted.
> > 
> > Well, please make up your mind with:
> > 
> > Option (1):
> > 
> > #define clear_bit                     clear_bit_mode(..., RELEASE)
> > #define Smp_mb__before_clear_bit      do { } while (0)
> > #define Smp_mb__after_clear_bit       smp_mb()
> > 
> > Or option (2):
> > 
> > #define clear_bit                     clear_bit_mode(..., ACQUIRE)
> > #define Smp_mb__before_clear_bit      smp_mb()
> > #define Smp_mb__after_clear_bit       do { } while (0)
> > 
> > I'm fine with either one.
> 
> Neither one is correct because there will always be one combination of 
> clear_bit with these macros that does not generate the required memory 
> barrier.

Can you give an example?  Which combination?

- Ken
