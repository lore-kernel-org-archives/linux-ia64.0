From: Don Dugger <n0ano@valinux.com>
Date: Wed, 05 Sep 2001 17:26:40 +0000
Subject: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805122@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David-

No, you can actually check the architecture type in `dlopen' and discover
that you are trying to use the wrong library.  (That's what I used to do
before you discovered the better way of using the `/etc/ld.so.cache'.)

Having said that I don't have a real strong opinion on this.  You could
try `/usr/ia32' first and, if there is a file there then it must be the
one you want and if it isn't there then try the original path.  Or, try
the orignal path and, if it isn't there or has the wrong architecture,
try the modified path.  Either way works.

On Wed, Sep 05, 2001 at 09:49:24AM -0700, David Mosberger wrote:
> >>>>> On Wed, 5 Sep 2001 10:47:42 -0600, Don Dugger <n0ano@valinux.com> said:
> 
>   Don> Bill raises an interesting problem.  I'd like to suggest a
>   Don> solution and see what everyone thinks.  Since all of the shared
>   Don> objects are loaded by code in `ld-linux.so' I can modify the
>   Don> IA32 version of that library to first try an absolute path and,
>   Don> if that fails, because it's missing or has the wrong
>   Don> architecture, to then tack on a unique prefix, either something
>   Don> like `/usr/ia32' or the contents of an environment variable
>   Don> like `LD_IA32_PATH'.
> 
> Wouldn't you have to try the prefix first?  Otherwise, you might end
> up picking up an ia64 library.
> 
> 	--david
> 
> 
> 
> _______________________________________________
> ia64-list mailing list
> ia64-list@redhat.com
> https://listman.redhat.com/mailman/listinfo/ia64-list

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

