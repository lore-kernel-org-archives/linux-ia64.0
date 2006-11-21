From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Tue, 21 Nov 2006 12:19:03 +0000
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061121121903.GC8122@osiris.boeblingen.de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com> <20061121113708.GB8122@osiris.boeblingen.de.ibm.com> <20061121211937.e25dceb8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061121211937.e25dceb8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, schwidefsky@de.ibm.com

> > I'd love to go for a generic implementation, but if that is based on
> > sparsemem it doesn't make too much sense on s390.
> 
> 'What type of vmem_map is supported ?' is maybe per-arch decision not generic.
> If people dislikes Flat/Discontig/Sparsemem complication, some clean
> up patch will be posted and discussion will start. If not, nothing will happen.

Ok, I will work on the s390 arch specific patch and post it here. Maybe it's
worth adding a generic vmem_map interface, maybe not. We'll see.
