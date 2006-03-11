From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 11 Mar 2006 20:17:39 +0000
Subject: RE: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <200603112017.k2BKHcg20412@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060310082445.GA18715@verge.net.au>
In-Reply-To: <20060310082445.GA18715@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote on Saturday, March 11, 2006 12:52 AM
> > I was actually thinking that the main drawback of this appoach was the
> > extra space devoted to these variables. Marking them as __init made the
> > linker very unhappy. Given their current delaration, will they just
> > stick around forever?
> > 
> 
> Yous hould be able to mark them __init, otherwise they just end up
> sticking around forever as you say. Grep around some other code in the
> vicinity to see how it's declared if it causes problems.

You should use __initdata.

- Ken

