From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 13 Dec 2005 15:42:28 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <439EEBE4.5080203@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is sort of a mini-RFC for linux-ia64 -- just to see if anyone objects to 
the solution before I implement it.  I'll throw this out onto lkml after I get 
some input here.

I spent the past day or so looking at a couple of solutions to this problem and 
the only solution that appears viable is to (as stated previously) create new 
initcalls of the form

platform_calltype_initcall(fn,platform)

ex)
	platform_device_initcall(sn_prarit_driver, "sn2");

which would check the platform type prior to loading a kernel.

As it turns out this is a little bit more tricky than I thought as the initcalls 
are placed in a list of initcalls in the .initcall section.

do_initcalls then goes through this list in order to run the various initcalls 
on the list.

Since the macro calltype_initcall is placing the specified function in the 
.initcall list we cannot do

if (ia64_platform_is(foo))
	platform_calltype_initcall(fn,platform)

So I'm modifying my original suggestion.  We will still have

platform_calltype_initcall(fn,platform)

ex)

platform_device_initcall(sn_prarit_driver, IA64_PLATFORM_SN2);

but instead of doing the above wrapper, we would create a new section called 
.platform (name of the section is open to debate) and would traverse both the 
.initcall and the .platform sections at the sametime.

Therefore the could would be something like (this is based off the existing 
do_initcalls)

for (call = __initcall_start, platform = __platform_start;
      call < __initcall_end; call++, platform++) {


	if (platform = __platform_end)
		panic(); /* BUG? size(.platform) != size(!initcall) */

	if (platform && IA64_PLATFORM)
		(*call)();

where platform would be some bitmask that represents the various flavours of 
ia64 that the initcall can run on, and IA64_PLATFORM is set very early in the init.

A few other things:

- by default the value of platform would default to all platforms.

ie)
	device_initcall(sn_prarit_driver)

resolves to

	platform_device_initcall(sn_prarit_driver, IA64_PLATFORM_ALL);

- maybe there should be a runtime warning noting that you are using initcall or 
calltype_initcall on ia64?  (Someone convince me that this is really needed)

- I passed this by an ia64 engineer from HP and he made the comment that the 
nice thing about Linux is that the initcalls on all platforms are handled in 
EXACTLY the same manner.  I sort of agree with his assessment, however, no other 
  arch in Linux can compile a generic kernel and run on all of it's subarches...

Suggestions/comments?  Anyone think this is too much bother for the original 
issue of avoiding

	if (!ia64_platform_is("sn2"))
		return -ENOSYS;

?

P.
