From: n0ano@indstorage.com
Date: Tue, 13 Nov 2001 15:15:56 +0000
Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805492@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David-

Yeah, as I said to Hideki I'll look into this.  It might take a
day or so, I can only do it in the evenings and I spent all last
night configuring a `named' server (talk about a painfull experience :-(

On Mon, Nov 12, 2001 at 03:58:06PM -0800, David Mosberger wrote:
> But I think the page size problem with brk() is real and can be fixed
> quite easily.  If I understood correctly, the problem is that doing
> something along the lines of:
> 
> 	x = ALIGN_TO_4K(sbrk(8192));
> 	memset(x, 0xff, 4096);
> 	brk(x);
> 	brk(x+4096);	
> 
> might preserve the contents of the page at X on under the ia32
> subsystem of ia64 when in fact it should be cleared to zero.
> 
> Would you be able/interested into looking into this?
> 
> 	--david

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

