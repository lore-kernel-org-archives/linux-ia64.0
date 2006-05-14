From: "H. Peter Anvin" <hpa@zytor.com>
Date: Sun, 14 May 2006 22:34:34 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <4467B07A.5010006@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Woodhouse wrote:
> On Sun, 2006-05-14 at 15:03 -0700, H. Peter Anvin wrote:
>> Keep in mind that userland isn't necessarily glibc.  In particular,
>> for klibc it would be a pain in the arse to have two largely identical
>> copies of the same header file in the kernel tree.
> 
> You can still use the copy from the kernel tree even if we don't
> actually copy it out in 'make headers_install'.
> 
> But yes, this is one of the reasons I haven't touched elf.h (yet).

I could, but that would defeat the purpose somewhat.

I believe "make headers_install" isn't "this is what userspace *has* to 
get from the kernel" (which is, after all, the null set -- people wrote 
C libraries for DOS for example), but "this is what the kernel provides 
to userspace."  It's up to userspace to use it or not, depending on the 
suitability for any one particular userspace.

	-hpa
