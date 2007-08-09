From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Aug 2007 23:35:06 +0000
Subject: RE: mmap broken?
Message-Id: <617E1C2C70743745A92448908E030B2A02213DEF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430708091102q26cc5a39uf67210652e7354c2@mail.gmail.com>
In-Reply-To: <ed5aea430708091102q26cc5a39uf67210652e7354c2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> There is a libunwind test-case that used to work fine but fails with
> recent kernels (e.g., 2.6.23-rc2).  The problem is exhibited by the
> attached test program.  It attempts to map the page right after the
> register-backing-store area with a no-access page.  The mmap call
> succeeds, but the kernel incorrectly maps the no-access page not at
> the desired location, but at the next page.  If I specify MAP_FIXED,
> the mmap() call succeeds, but I don't think MAP_FIXED should be
> necessary here.  Anybody can think of any patches that would explain
> this change of behavior?

It's perfectly legal for the OS to ignore the address if you don't
specify the MAP_FIXED flag.  The "start" argument to mmap is just a
hint.

Possibly some code is trying to leave a red-zone between mapped
areas?  Or perhaps we just have an off-by-one error when computing
the address.

-Tony
