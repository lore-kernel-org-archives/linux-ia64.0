From: David Howells <dhowells@redhat.com>
Date: Wed, 14 Jul 2004 07:54:24 +0000
Subject: Re: [PATCH] 2.6.8-rc1 including AFS in ia64 and other ARCHS builds breaks the compilation
Message-Id: <9906.1089791664@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040714010706.GA31683@cse.unsw.EDU.AU> 
In-Reply-To: <20040714010706.GA31683@cse.unsw.EDU.AU> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Darren Williams <dsw@gelato.unsw.edu.au>
Cc: Ia64 Linux <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>


Andrew Morton has a fix for this that involves removing struct_cpy() entirely
and going for direct assignment instead.

David
