From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Mar 2004 21:57:02 +0000
Subject: RE: Question about ia64 linux
Message-Id: <16480.45742.317088.475004@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAY14-F301ImxoKYUVs0007e432@hotmail.com>
In-Reply-To: <BAY14-F301ImxoKYUVs0007e432@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 21 Mar 2004 22:13:23 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> The software developers manual covers everything that
  Tony> you need to know.

True, but if you modify code in such a way that it affects a
procedure's call-frame, then you need to patch the unwind info as
well, and that's not discussed in these manuals.  The Software
Convention and Runtime Architecture does discuss unwind info, but
doesn't directly address the issue of runtime-generated code.  The
libunwind API (http://www.hpl.hp.com/research/linux/libunwind/) has
support for (efficiently) describing runtime-generated code but, alas,
this API isn't used in the kernel yet.  And even if it were, it's
unlikely the dynamic unwind info support would be enabled for the
kernel (not until someone demonstrates a real need for having a JIT in
the kernel, at least ;-).

	--david
