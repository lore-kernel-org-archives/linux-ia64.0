From: Arjan van de Ven <arjanv@redhat.com>
Date: Fri, 23 May 2003 08:30:32 +0000
Subject: Re: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723706001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 22, 2003 at 06:07:46PM -0700, Hans Boehm wrote:
> case.
> 
> On a 1GHz Itanium 2 I get
> 
> Custom lock: 180 msecs
> Custom lock: 1382 msecs
> 
> On a 2GHz Xeon, I get
> 
> Custom lock: 646 msecs
> Custom lock: 1659 msecs

is the pthreads one with nptl ?

