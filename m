From: David Miller <davem@davemloft.net>
Date: Tue, 25 Mar 2008 23:32:40 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.163240.102401706.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<20080324.211532.33163290.davem@davemloft.net>
	<18408.59112.945786.488350@cargo.ozlabs.ibm.com>
In-Reply-To: <18408.59112.945786.488350@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulus@samba.org
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

From: Paul Mackerras <paulus@samba.org>
Date: Tue, 25 Mar 2008 22:50:00 +1100

> How do I get gcc to use hugepages, for instance?

Implementing transparent automatic usage of hugepages has been
discussed many times, it's definitely doable and other OSs have
implemented this for years.

This is what I was implying.
