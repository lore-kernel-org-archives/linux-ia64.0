From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 May 2003 00:01:00 +0000
Subject: Re: [Linux-ia64] Re: new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705741@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705722@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705722@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 11 May 2003 00:02:50 +1000, 
Keith Owens <kaos@sgi.com> wrote:
>* Always save the return address in r28 in addition to b6 ...
>  ... kernprof only gets the minstate
>  data and it needs the return address to report the real contention
>  code.

Ignore that last bit, b6 is in pt_regs.  I don't know what I was
thinking when I wrote that.  But the bit about not appearing in the
INIT/MCA minstate dump still applies.


