From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Jan 2001 02:35:12 +0000
Subject: Re: [Linux-ia64] PATCH:  Building on ia32
Message-Id: <marc-linux-ia64-105590693005073@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005061@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005061@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Jan 2001 13:12:41 -0500 (EST), William Taber <wtaber@rational.com> said:

  William> When I downloaded Linux 2.4.0 and applied the
  William> linux-2.4.0-ia64-010109.diff patch, I discovered that I could no
  William> longer compile ia32 kernels.  It turned out that there were
  William> reletively few changes needed to get the ia32 kernel to compile
  William> cleanly and come up and run. As I promised yesterday, here are the
  William> patches I needed to make.  This may not be exhaustive, since I do not
  William> have all options turned on and I didn't try to build many
  William> drivers. Note that this patch will remove the buggy code that I
  William> reported yesterday, rather than just conditionalizing it.  Since the
  William> code was broken and would not run properly, as well as being
  William> non-portable, I just took it out pending a fix.  In the interest of
  William> getting the latest ia64 changes ready for merging into the the main
  William> 2.4.x tree at some point, here are the diffs.

But your patch breaks the lazy-execute bit scheme that IA-64 relies on to avoid
cache flushing.  Your kernel will probably hang on any app that does dynamic
code generation (e.g., such as due to nested C functions).

You're probably better off implementing is_exec_access() on x86 as always
returning 0.

	--david

