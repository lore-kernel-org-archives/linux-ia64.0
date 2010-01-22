From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 22 Jan 2010 14:43:32 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001220842340.2704@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com>
 <alpine.DEB.2.00.1001191545170.26683@router.home> <20100121214749.GJ17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211643020.20071@router.home> <20100121230551.GO17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211737360.20719@router.home>
 <20100122001534.GB30417@ldl.fc.hp.com>
In-Reply-To: <20100122001534.GB30417@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Thu, 21 Jan 2010, Alex Chiang wrote:

> > Difficult since I also did not track how this belonged together. Sorry.
>
> Replying and cc'ing so akpm sees this as our final answer. :)

Well I think this is going through the git tree for slab allocators via
Pekka.
