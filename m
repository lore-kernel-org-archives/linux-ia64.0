From: Richard Guenther <rguenther@suse.de>
Date: Thu, 02 Feb 2012 09:37:59 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LNX.2.00.1202021037180.4999@zhemvz.fhfr.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328114266.5355.44.camel@lenny> <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com> <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz> <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
 <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
In-Reply-To: <CA+55aFxt3rG8_HyoRqiMOKVDqaGTkRk=Kh+bAJTAxxdHAGzuVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Matz <matz@suse.de>, Jiri Kosina <jkosina@suse.cz>, Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, gcc@gcc.gnu.org

On Wed, 1 Feb 2012, Linus Torvalds wrote:

> Just out of morbid curiosity, what happens if you have totally
> *separate* variables that just happen to link together? IOW, something
> like
> 
>    static struct { unsigned bit:1; } onebit;
>    static volatile int var;
> 
> and they just *happen* to link next to each other (because they were
> declared next to each other) in the same 8-byte aligned block?

Just to make you run away screaming ...

http://gcc.gnu.org/bugzilla/show_bug.cgi?idH124

where exactly such situation happens ...

Richard.
