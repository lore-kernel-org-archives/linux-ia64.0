From: Don Dugger <n0ano@n0ano.com>
Date: Thu, 14 Nov 2002 15:10:08 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805427@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I sometimes prefer a routine to return a pointer, even if the
pointer is known in advance.  This way you can set a pointer
in the same statement that does the copy, e.g.:

	ptr = memcpy(malloc(100), buffer, 100);

rather than:

	ptr = malloc(100);
	memcpy(ptr, buffer, 100);

This is just a stylistic issue, I like to remove lines of code
whenever possible.

PS:  I would never actually do this code example, using a malloc
without checking the result is wrong, but you get the idea.

On Thu, Nov 14, 2002 at 10:01:44AM +0100, Christian Cotte-Barrot wrote:
> "Chen, Kenneth W" wrote:
> > 
> > The retrun value for memcpy doesn't follow the user space memcpy exactly.
> > kernel memcpy always return 0.
> > - Ken
> > 
> 
> But memcpy from memcpy.S is returning a pointer to dest area.
> That would lead to quasi non-portable code when the return from memcopy
> is correctly checked depending on which memcopy function is addressed.
> But BTW, is it meaningful to take into account a return code
> that is always the same and which value is known in advance ?
> Does memcpy suppose to failed in some cases ?
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com

